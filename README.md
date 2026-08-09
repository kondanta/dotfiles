# dotfiles

Personal dotfiles for CachyOS / Hyprland managed with [chezmoi](https://www.chezmoi.io/).

## Prerequisites

- `chezmoi`
- `age` (for encrypted files)

## Bootstrap

```sh
chezmoi init --source ~/dev/homelab/dotfiles
chezmoi apply
```

Place your age decryption key at `~/.config/chezmoi/key.txt` before running `chezmoi apply` if you need access to encrypted files (e.g. Halloy config).

## Encryption

Secrets are encrypted with [age](https://age-encryption.org/). Encrypted files carry the `.age` suffix in the source directory.

## Structure

```
dot_config/
├── caelestia/        # Caelestia shell
├── claude/           # Claude Code
├── emacs/            # Emacs (init.el, config.org only)
├── easyeffects/      # Audio processing
├── fish/             # Fish shell
├── foot/             # Foot terminal
├── fuzzel/           # App launcher
├── hypr/             # Hyprland WM
├── jj/               # Jujutsu VCS
├── kitty/            # Kitty terminal
├── mozilla/          # Firefox (user.js + chrome CSS/JS only)
├── noctalia/         # Caelestia bar config
├── private_atuin/    # Shell history sync
├── private_halloy/   # IRC client (config encrypted)
├── private_jj/       # Jujutsu private config
├── private_spicetify/# Spotify theming
├── quickshell/       # Quickshell widgets
├── starship.toml     # Shell prompt
├── tmux/             # Tmux
├── user-scripts/     # Custom scripts
├── uwsm/             # Universal Wayland session manager
└── zed/              # Zed editor
```
