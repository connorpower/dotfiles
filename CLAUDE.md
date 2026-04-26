# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal dotfiles managed via symlinks. No build step, no tests. Everything is plain config files and bash scripts.

Supported targets: `darwin` (macOS), `debian` (Ubuntu/WSL2), `arch` (Arch Linux), `msys2` (Windows).

## Key scripts

**`bootstrap.sh`** — creates symlinks from repo files to their system destinations.

```sh
./bootstrap.sh          # link all files for detected OS
./bootstrap.sh -d       # dry run (prints commands, changes nothing)
./bootstrap.sh -f       # force-overwrite existing files
./bootstrap.sh -l       # list all destination paths (pipeable)
```

**`packages/install.sh`** — installs packages via the OS package manager + cargo + rustup.

```sh
./packages/install.sh base              # installs base packages for all machines
./packages/install.sh base personal     # base + personal packages
./packages/install.sh base personal ditto  # all categories (includes work tooling)
./packages/install.sh -d base           # dry run
```

**`bin/detect-os`** — prints one of `darwin`, `arch`, `debian`, `msys2`. Used internally by both scripts.

## Architecture

### Symlink model

`bootstrap.sh` maintains a `FILES` array mapping `$HOME/...destination -> repo/path`. Running the script creates symlinks. To add a new dotfile: add it to the `FILES` array (or `FILES_DARWIN`/`FILES_DEBIAN`/`FILES_ARCH` for OS-specific), then run `bootstrap.sh`.

The `TEMPLATE_LINKS` mechanism handles files where the target path contains `<OS>` — e.g., `kitty/os.conf` resolves to `kitty/kitty-darwin.conf` on macOS.

### Package model

`packages/packages.yml` organises packages into categories (`base`, `personal`, `ditto`) and sub-keys (`universal`, `cargo`, `darwin`, `arch`, `arch-aur`, `debian`). `install.sh` uses `yq` to query this YAML and dispatches to the correct package manager. Cargo packages are always installed with `--locked`.

### OS-specific zsh includes

`zsh/rc` sources files from `zsh/zsh.d/` conditionally:
- `macos.zsh` / `arch.zsh` / `msys2.zsh` / `debian-wsl2.zsh` — loaded based on `$OS`
- `ditto.zsh` — loaded only when `~/.config/zsh.d/enable-ditto` exists (work machine opt-in)
- `vim-mode.zsh`, `aws-utils.zsh`, `dates.zsh`, `stand.zsh` — always loaded

### Git config layering

`git/gitconfig` includes `~/.gitconfig-os` which is a symlink to either `git/gitconfig-darwin` or `git/gitconfig-debian` depending on OS. This is where OS-specific git settings (e.g. GPG agent config) live. GPG signing is enabled globally; signing key is `EC2399A673BBCD1F`.
