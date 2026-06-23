# Dotfiles

Personal dotfiles managed with [chezmoi](https://chezmoi.io).

## Layout

```
.
├── brew/Brewfile     # Packages (not managed by chezmoi — applied manually)
└── chezmoi/          # chezmoi source dir (see .chezmoiroot)
    ├── .chezmoi.toml.tmpl     # Prompts for email + is_work_computer on init
    ├── .chezmoiscripts/       # run_after_iterm.sh sets iTerm2 prefs folder
    ├── assets/                # iTerm2 + Claude statusline assets (symlinked in)
    ├── dot_claude/            # ~/.claude (statusline symlink)
    ├── dot_config/            # ~/.config (git, zsh, nvim, oh-my-posh, iTerm2)
    ├── modify_dot_zshrc       # ~/.zshrc generator (preserves content below marker)
    └── create_dot_zshrc.local  # seeded once at ~/.zshrc.local, never overwritten
```

## Setup

```sh
# 1. Install chezmoi + brew packages
brew install chezmoi
git clone https://github.com/ben-732/dotfiles ~/.local/share/chezmoi
brew bundle --file=~/.local/share/chezmoi/brew/Brewfile

# 2. Apply (prompts for email + work-computer flag)
chezmoi apply
```

On macOS, `chezmoi apply` also points iTerm2 at `assets/iterm/` for prefs.

## Per-machine config

Anything machine-specific goes in `~/.zshrc.local` (sourced last by `.zshrc`). chezmoi seeds an empty stub on first apply and never overwrites it. The `zl` alias opens it in `$EDITOR`.
