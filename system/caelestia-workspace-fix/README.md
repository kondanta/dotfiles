# caelestia-workspace-fix

Patches applied to `caelestia-shell` after package installs/upgrades.

## Files

| Source (this repo) | System path |
|---|---|
| `fix.py` | `/usr/local/lib/caelestia-workspace-fix/fix.py` |
| `caelestia-workspace-fix.hook` | `/etc/pacman.d/hooks/caelestia-workspace-fix.hook` |

## What it fixes

1. **shell.qml** — strips `DefaultEnv` pragmas that `quickshell-git` doesn't support (causes blank UI)
2. **Workspaces.qml** — patches workspace bar click handler to work with Lua dispatch

## Deploying after changes

```fish
sudo cp fix.py /usr/local/lib/caelestia-workspace-fix/fix.py
sudo cp caelestia-workspace-fix.hook /etc/pacman.d/hooks/caelestia-workspace-fix.hook
```
