---
name: deslop
description: Remove AI-generated code slop and clean up code style
---

# Remove AI code slop

Check the diff against main and remove AI-generated slop introduced in the branch.

## Focus Areas

- Extra comments that are unnecessary or inconsistent with local style
- Defensive checks, redundant `unwrap_or_default()`, or `.unwrap_or(Default::default())` chains abnormal for trusted code paths
- Spurious `.clone()` calls added only to satisfy the borrow checker without thought
- Unnecessary `pub` visibility on items that don't cross a module boundary
- `unwrap()` replaced with verbose `.expect("should never happen")` noise where a real error type belongs
- Casts to `as usize` / `as i64` / etc. used only to paper over a type mismatch rather than fix the root type
- Deeply nested `match` or `if let` chains that should be flattened with early returns, `?`, or combinators (`map`, `and_then`, `ok_or`)
- Blanket `#[allow(dead_code)]` or `#[allow(unused_variables)]` added to suppress warnings instead of fixing the underlying issue
- Overly defensive `is_empty()` / `len() == 0` guards before operations that already handle the empty case
- Other patterns inconsistent with the file and surrounding codebase

## Guardrails

- Keep behavior unchanged unless fixing a clear bug.
- Prefer minimal, focused edits over broad rewrites.
- Keep the final summary concise (1-3 sentences).
