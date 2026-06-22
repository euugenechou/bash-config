# dotfiles-bash

Portable Bash config with [ble.sh](https://github.com/akinomyoga/ble.sh) for autosuggestions, syntax highlighting, and vi-mode.

## Install

```bash
git clone --recursive <repo-url> ~/dotfiles-bash
cd ~/dotfiles-bash
./install.sh
```

This will:
1. Build ble.sh (requires `make` and `gawk`)
2. Symlink `~/.bashrc` and `~/.inputrc` (existing files are backed up)
3. Report any missing optional dependencies

Then restart your shell.

## Uninstall

```bash
./install.sh --uninstall
```

Removes symlinks and restores your previous config from backup.

## Optional dependencies

All optional — the config degrades gracefully without them.

| Tool | Used for |
|------|----------|
| [eza](https://github.com/eza-community/eza) | `ls`/`ll`/`la`/`l` aliases |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy history search, completion |
| [direnv](https://github.com/direnv/direnv) | Per-directory env vars |

## Structure

```
bashrc           # ble.sh init/attach, sources conf.d/*
inputrc          # Fallback readline config (vi-mode)
install.sh       # Bootstrap / uninstall
conf.d/
  aliases.bash   # Shell aliases
  appearance.bash # Prompt and ble.sh syntax highlighting
  options.bash   # Shell options and history
  path.bash      # PATH additions
  tools.bash     # fzf, direnv, cargo integrations
blesh/           # ble.sh (git submodule)
```

Drop a new `.bash` file into `conf.d/` and it gets sourced automatically.
