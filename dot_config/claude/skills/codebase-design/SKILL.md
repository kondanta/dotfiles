---
name: codebase-design
description: Shared vocabulary for designing deep modules. Use when the user wants to design or improve a module's interface, find deepening opportunities, decide where a seam goes, make code more testable or AI-navigable, or when another skill needs the deep-module vocabulary.
---

# Codebase Design

Design **deep modules**: a lot of behaviour behind a small interface, placed at a clean seam, testable through that interface. Use this language and these principles wherever code is being designed or restructured. The aim is leverage for callers, locality for maintainers, and testability for everyone.

## Glossary

Use these terms exactly: don't substitute "component," "service," or "boundary." Consistent language is the whole point.

**Module**: anything with an interface and an implementation. Deliberately scale-agnostic: a function, struct, trait, crate, or tier-spanning slice. _Avoid_: unit, component, service.

**Interface**: everything a caller must know to use the module correctly: the trait or function signature, but also invariants, ordering constraints, error modes, required configuration, lifetime constraints, and performance characteristics. _Avoid_: API, signature (too narrow — they refer only to the type-level surface).

**Implementation**: what's inside a module — the body of code behind the `impl` block or function. Distinct from **Adapter**: a thing can be a small adapter with a large implementation (a Postgres repo) or a large adapter with a small implementation (an in-memory fake). Reach for "adapter" when the seam is the topic; "implementation" otherwise.

**Depth**: leverage at the interface. The amount of behaviour a caller (or test) can exercise per unit of interface they have to learn. A module is **deep** when a large amount of behaviour sits behind a small interface, **shallow** when the interface is nearly as complex as the implementation.

**Seam** _(Michael Feathers)_: a place where you can alter behaviour without editing in that place; the _location_ at which a module's interface lives. Where to put the seam is its own design decision, distinct from what goes behind it. In Rust, seams are most naturally expressed as traits. _Avoid_: boundary (overloaded with DDD's bounded context).

**Adapter**: a concrete struct that satisfies a trait at a seam. Describes _role_ (what slot it fills), not substance (what's inside).

**Leverage**: what callers get from depth. More capability per unit of interface they learn. One implementation pays back across N call sites and M tests.

**Locality**: what maintainers get from depth. Change, bugs, knowledge, and verification concentrate in one place rather than spreading across callers. Fix once, fixed everywhere.

## Deep vs shallow

**Deep module** = small interface + lots of implementation:

```
┌─────────────────────┐
│   Small Interface   │  ← Few trait methods, simple types
├─────────────────────┤
│                     │
│  Deep Implementation│  ← Complex logic hidden
│                     │
└─────────────────────┘
```

**Shallow module** = large interface + little implementation (avoid):

```
┌─────────────────────────────────┐
│       Large Interface           │  ← Many methods, complex params
├─────────────────────────────────┤
│  Thin Implementation            │  ← Just passes through
└─────────────────────────────────┘
```

When designing an interface, ask:

- Can I reduce the number of trait methods?
- Can I simplify the parameters — fewer, more compositional types?
- Can I hide more complexity inside (error handling, retries, encoding)?

## Principles

- **Depth is a property of the interface, not the implementation.** A deep module can be internally composed of small, mockable, swappable parts; they just aren't part of the interface. A module can have **internal seams** (private to its implementation, used by its own tests) as well as the **external seam** at its interface.
- **The deletion test.** Imagine deleting the module. If complexity vanishes, it was a pass-through. If complexity reappears across N callers, it was earning its keep.
- **The interface is the test surface.** Callers and tests cross the same seam. If you want to test _past_ the interface, the module is probably the wrong shape.
- **One adapter means a hypothetical seam. Two adapters means a real one.** Don't introduce a trait unless something actually varies across it.

## Designing for testability

Good interfaces make testing natural. Rust's ownership model and trait system provide powerful primitives — use them.

### 1. Accept dependencies, don't create them (dependency injection via traits)

```rust
// Testable: caller injects the gateway
fn process_order(order: Order, gateway: &dyn PaymentGateway) -> Result<Receipt, PaymentError> {
    gateway.charge(order.total)
}

// Hard to test: constructs its own dependency
fn process_order(order: Order) -> Result<Receipt, PaymentError> {
    let gateway = StripeGateway::new();   // can't swap this in tests
    gateway.charge(order.total)
}
```

Prefer `&dyn Trait` for runtime polymorphism or generics + trait bounds (`T: PaymentGateway`) for zero-cost dispatch. Use `Arc<dyn Trait>` when shared ownership across threads is needed.

### 2. Return results, don't hide effects

```rust
// Testable: pure calculation, no side effects
fn calculate_discount(cart: &Cart) -> Discount {
    // ...
}

// Hard to test: mutates in place, no observable return value
fn apply_discount(cart: &mut Cart) {
    cart.total -= compute_discount(cart);
}
```

Prefer functions that return `Result<T, E>` or a computed value over functions that mutate in place. When mutation is necessary, make the mutation the _only_ thing the function does — separate calculation from application.

### 3. Use `Result` and `?` at seams, not panics

```rust
// Good: caller decides how to handle failure
pub fn load_config(path: &Path) -> Result<Config, ConfigError> { ... }

// Bad: panics are not part of the interface contract
pub fn load_config(path: &Path) -> Config {
    std::fs::read_to_string(path).expect("config must exist")
}
```

Errors are part of the interface. Panics are not — they collapse the interface to a binary "works / crashes." Use typed errors (`thiserror`, `anyhow`) so the caller can reason about failure modes.

### 4. Small surface area

Fewer trait methods = fewer items to implement for fakes/mocks = simpler test setup. A trait with one method is almost always deep enough. Prefer:

```rust
// One focused method — easy to fake
trait EventSink {
    fn emit(&self, event: Event) -> Result<(), SinkError>;
}

// Over a sprawling trait that forces implementors to stub everything
trait EventSystem {
    fn emit(&self, event: Event) -> Result<(), SinkError>;
    fn subscribe(&self, topic: &str, handler: Box<dyn Fn(Event)>);
    fn flush(&self) -> Result<(), SinkError>;
    fn metrics(&self) -> SinkMetrics;
}
```

### 5. Newtype wrappers over primitive obsession

Prefer wrapping primitives in newtypes at seam boundaries. It narrows the interface and encodes invariants in the type system rather than in comments.

```rust
// Shallow — any i64 can be passed; mistakes compile
fn transfer(from: i64, to: i64, amount: i64) -> Result<(), Error> { ... }

// Deeper — the type carries meaning; swapping args is a type error
fn transfer(from: AccountId, to: AccountId, amount: Cents) -> Result<(), Error> { ... }
```

## Rust-specific seam patterns

### Trait objects for runtime-swappable adapters

```rust
pub trait Repository {
    fn find(&self, id: Uuid) -> Result<Record, RepoError>;
    fn save(&self, record: &Record) -> Result<(), RepoError>;
}

pub struct PostgresRepo { pool: PgPool }
impl Repository for PostgresRepo { ... }

// In tests — no database needed
pub struct InMemoryRepo { store: Mutex<HashMap<Uuid, Record>> }
impl Repository for InMemoryRepo { ... }
```

### Generic bounds for zero-cost adapters

```rust
pub struct OrderService<G: PaymentGateway, R: Repository> {
    gateway: G,
    repo: R,
}

impl<G: PaymentGateway, R: Repository> OrderService<G, R> {
    pub fn place(&self, order: Order) -> Result<Receipt, ServiceError> { ... }
}
```

Zero runtime overhead. The concrete types are resolved at compile time, and tests substitute fakes without `dyn` dispatch.

### `#[cfg(test)]` fakes over external mocking frameworks

Rust's mock libraries (mockall, etc.) add complexity quickly. Prefer simple hand-written fakes inside `#[cfg(test)]` modules — they're usually 10-20 lines and make the seam's contract explicit:

```rust
#[cfg(test)]
mod tests {
    use super::*;

    struct FakeGateway { should_fail: bool }
    impl PaymentGateway for FakeGateway {
        fn charge(&self, _amount: Cents) -> Result<Receipt, PaymentError> {
            if self.should_fail { Err(PaymentError::Declined) } else { Ok(Receipt::test()) }
        }
    }

    #[test]
    fn declined_payment_returns_error() {
        let svc = OrderService::new(FakeGateway { should_fail: true }, InMemoryRepo::new());
        assert!(matches!(svc.place(Order::test()), Err(ServiceError::PaymentFailed)));
    }
}
```

## Relationships

- A **Module** has exactly one **Interface** (the surface it presents to callers and tests — the trait or public function set).
- **Depth** is a property of a **Module**, measured against its **Interface**.
- A **Seam** is where a **Module**'s **Interface** lives — in Rust, most naturally a `trait`.
- An **Adapter** is a `struct` that `impl`s the trait at a **Seam**.
- **Depth** produces **Leverage** for callers and **Locality** for maintainers.

## Rejected framings

- **Depth as ratio of implementation-lines to interface-lines** (Ousterhout): rewards padding the implementation. We use depth-as-leverage instead.
- **"Interface" as the set of `pub` methods on a struct**: too narrow — the interface here includes every fact a caller must know, including `Send + Sync` bounds, `'static` requirements, and error modes.
- **"Boundary"**: overloaded with DDD's bounded context. Say **seam** or **interface**.
- **Avoiding traits to stay "simple"**: a bare `struct` with no trait is fine until you need a seam. When two adapters exist, add the trait. Not before.

## Going deeper

- **Deepening a cluster given its dependencies**, see [DEEPENING.md](DEEPENING.md): dependency categories, seam discipline, and replace-don't-layer testing.
- **Exploring alternative interfaces**, see [DESIGN-IT-TWICE.md](DESIGN-IT-TWICE.md): spin up parallel sub-agents to design the interface several radically different ways, then compare on depth, locality, and seam placement.
