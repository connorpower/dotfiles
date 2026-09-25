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
./bootstrap.sh -f       # delete files in the way instead of backing them up
./bootstrap.sh -l       # list all destination paths (pipeable)
```

**`packages/install.sh`** — installs packages via the OS package manager + cargo + rustup.

```sh
./packages/install.sh base              # installs base packages for all machines
./packages/install.sh base personal     # base + personal packages
./packages/install.sh base personal work   # all categories (includes work tooling)
./packages/install.sh -d base           # dry run
```

**`bin/detect-os`** — prints one of `darwin`, `arch`, `debian`, `msys2`. Used internally by both scripts.

## Architecture

### Symlink model

`bootstrap.sh` maintains a `FILES` array mapping `$HOME/...destination -> repo/path`. Running the script creates symlinks. To add a new dotfile: add it to the `FILES` array (or `FILES_DARWIN`/`FILES_DEBIAN`/`FILES_ARCH` for OS-specific), then run `bootstrap.sh`.

If a real file (or stale symlink) already sits at a destination, `bootstrap.sh` moves it aside to `<dest>.backup.<YYYYmmddHHMMSS>` before linking and prints a summary of what it moved. `-f` deletes those instead of backing them up. Re-runs are idempotent — a destination already pointing at the right repo file is left untouched.

The `TEMPLATE_LINKS` mechanism handles files where the target path contains `<OS>` — e.g., `kitty/os.conf` resolves to `kitty/kitty-darwin.conf` on macOS.

### Claude Code skills

`claude/dotfiles-plugin/` is a Claude Code plugin, linked to `~/.claude/skills/dotfiles`. Any directory placed directly in `~/.claude/skills/` that carries a `.claude-plugin/plugin.json` is adopted as a plugin (`dotfiles@skills-dir`) at the start of the next session. Verify with `claude plugin list` and `claude plugin details dotfiles`.

Add a skill with `mkdir claude/dotfiles-plugin/skills/<name>` and a `SKILL.md` inside it. No `bootstrap.sh` change is needed — the single symlink covers the whole plugin. The directory can also hold `agents/`, `commands/` and `hooks/`.

Skills loaded this way are namespaced, so `technical-writing` is invoked as `dotfiles:technical-writing`.

Do not link `~/.claude/skills` itself. Claude Code owns that directory: it writes the claude.ai sync bucket to `~/.claude/skills/synced/`, and company or project tooling may add sibling entries. Linking the parent pulls all of that into this repo.

### Package model

`packages/packages.yml` organises packages into categories (`base`, `personal`, `work`) and sub-keys (`universal`, `cargo`, `cargo-<os>`, `darwin`, `arch`, `arch-aur`, `debian`, `scripts`). `install.sh` uses `yq` to query this YAML and dispatches to the correct package manager. Cargo packages are always installed with `--locked`. The `scripts` sub-key is for tools that ship their own curl-piped installer instead of a package-manager package; entries are `name@url`, and `name` is checked on `PATH` before running the installer.

Prefer a prebuilt package over a source build. Put a Rust tool in `cargo` only when no package manager ships it, and in `cargo-<os>` (for example `cargo-debian`) when one package manager lacks it and the others do not. A source build costs compile time on every machine, and it trades a reviewed distribution package for an unreviewed one. Check the package before you move a tool: `calc` on crates.io is a different program from the `calc` that brew, pacman, and apt ship.

Two apt packages install a binary under another name, because the obvious name was already taken. `bat` installs `batcat`, and `fd-find` installs `fdfind`. The `zsh` and `git` configs call both tools by their upstream names, so `configure()` in `install.sh` links each one into `~/.local/bin`.

### OS-specific zsh includes

`zsh/rc` sources files from `zsh/zsh.d/` conditionally:
- `macos.zsh` / `arch.zsh` / `msys2.zsh` / `debian-wsl2.zsh` — loaded based on `$OS`
- `work.zsh` — loaded only when `~/.config/zsh.d/enable-work` exists (work machine opt-in)
- `vim-mode.zsh`, `aws-utils.zsh`, `dates.zsh`, `stand.zsh` — always loaded

### Git config layering

`git/gitconfig` is the base. Everything signs with SSH, so no part of the config switches signature format. Two things layer on top:

1. `~/.gitconfig-os` — a symlink to `git/gitconfig-darwin` or `git/gitconfig-debian`. OS-specific settings such as the credential helper live here.
2. Two identity files, included in order. `~/.gitconfig-identity` always applies. `includeIf "gitdir:~/scm/work/"` then pulls in `~/.gitconfig-work-identity`, which overrides it inside the work tree. Git takes the last value it reads, so order in the file is what makes work win.

Identity follows the directory and nothing else. A repo outside `~/scm/work` gets the personal identity, wherever it pushes.

Neither identity file is in this repo, and neither is any key. Each holds a name, an email, and the path to a signing key, and `bootstrap.sh` copies each from a template in `git/` when the destination is missing. It never overwrites one you have filled in. The `TEMPLATE_FILES` array holds the mapping.

The same key has to be registered with each forge before signatures verify: GitHub under "SSH and GPG keys" with the type "Signing key", GitLab under "SSH Keys" with the usage type "Authentication & Signing". A key added for authentication alone signs fine and verifies nowhere.

`gpg.ssh.allowedSignersFile` points at `~/.config/git/allowed_signers`, which git needs to check a signature locally. Without it, every request for a verification result fails, including the `%G?` log format and `git verify-commit`, even though the commit is signed correctly.

That file is generated, not edited. `generate_allowed_signers()` in `bootstrap.sh` rewrites it on each run from the two identity files, one line per address. An identity is skipped until its email looks like an address and its signing key is readable, so a run before you fill in the templates is harmless. Fill in an identity and re-run.

An earlier version of this config signed with OpenPGP on GitHub and SSH on GitLab, and selected between them with eight `includeIf "hasconfig:remote.*.url:..."` blocks. Signing everything with SSH replaced all of it. If you ever need the per-remote form back, know that git matches the SCP form (`git@host:group/repo.git`) and the URL form (`https://host/group/repo.git`) with different globs, `*` never crosses a `/`, and each forge therefore needs four patterns.
