# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal dotfiles managed via symlinks. No build step, no tests. Everything is plain config files and bash scripts.

Supported targets: `darwin` (macOS), `debian` (Ubuntu/WSL2), `arch` (Arch Linux), `msys2` (Windows).

There is no code graph here, on purpose. `graft` indexes a codebase so that an agent can search summaries instead of source, which earns nothing against 79 files of config and two bash scripts. Running `graft init` in this repo writes per-file cards, a `.ignore` file, and machine-wide hook entries, so do not run it. `graft uninstall --no-global` reverses it and leaves other repos alone. The machine-wide hooks still write `graft/.cache`, which `.gitignore` covers.

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

### Skills

`agents/` is the version-controlled copy of `~/.agents/`, the cross-vendor directory that Codex and the ChatGPT desktop app read. It mirrors that layout exactly, so `agents/skills/<name>` in this repo is `~/.agents/skills/<name>` on the machine. Nothing in the path names one vendor, because nothing in it belongs to one.

`agents/skills/` holds the skills. Each one is a directory with a `SKILL.md` inside it, whose frontmatter carries a `name` and a `description`. That format is the Agent Skills standard, which Claude Code, Codex, and ChatGPT all read, so one copy of a skill serves every agent. Two sets of symlinks put it where each agent looks.

**Claude Code.** `agents/` is also a Claude Code plugin, linked to `~/.claude/skills/dotfiles`. Any directory placed directly in `~/.claude/skills/` that carries a `.claude-plugin/plugin.json` is adopted as a plugin (`dotfiles@skills-dir`) at the start of the next session. Verify with `claude plugin list` and `claude plugin details dotfiles`. The one link covers every skill, so a new skill needs no `bootstrap.sh` change for Claude.

The mirror is what keeps paths out of the manifest. A plugin scans `skills/` under its own root by default, and the `~/.agents/` layout already puts them there, so `.claude-plugin/plugin.json` carries metadata and nothing else. Run `claude plugin validate ./agents` after changing it.

Skills loaded this way are namespaced, so `technical-writing` is invoked as `dotfiles:technical-writing`.

**Codex and ChatGPT.** Codex scans `~/.agents/skills/` for user-level skills, and `.agents/skills/` in every directory from the working directory up to the repository root. It follows symlinks. Each skill is linked separately into `~/.agents/skills/<name>`, because linking the parent would pull in whatever Codex and ChatGPT install there themselves.

`bootstrap.sh` derives that list rather than holding it. A loop after the `CONSTANTS` section appends one mapping to `FILES` for every directory in `agents/skills/` that holds a `SKILL.md`. Adding a skill is therefore `mkdir agents/skills/<name>`, a `SKILL.md` inside it, and `bootstrap.sh`. No edit to the script, and `bootstrap.sh -l` lists the new skill like any other destination.

Claude Code puts a plugin's commands, hooks, and output styles beside its skills, which lands them at `agents/commands/`, `agents/hooks/`, and `agents/output-styles/`. Each one reads correctly under `agents/`. The single collision is subagents, which Claude Code expects at `agents/agents/`.

An `agents/openai.yaml` beside a `SKILL.md` sets the display name, description, and default prompt that the ChatGPT desktop app shows for that skill. Claude Code ignores the file. It sits inside one skill and has nothing to do with the top-level `agents/`.

Do not link `~/.claude/skills` or `~/.agents/skills` itself, only the entries inside them. Claude Code owns the first: it writes the claude.ai sync bucket to `~/.claude/skills/synced/`, and company or project tooling may add sibling entries. The second collects whatever Codex and ChatGPT install locally. Linking either parent pulls all of that into this repo.

`~/.codex/skills/` is a third location, written by the ChatGPT desktop app when it installs a skill. Nothing in this repo links there. A skill present both there and in `~/.agents/skills/` appears twice in the Codex skill selector, because Codex lists duplicate names rather than merging them.

### Package model

`packages/packages.yml` organises packages into categories (`base`, `personal`, `work`) and sub-keys (`universal`, `cargo`, `cargo-<os>`, `darwin`, `arch`, `arch-aur`, `debian`, `scripts`, `npm`). `install.sh` uses `yq` to query this YAML and dispatches to the correct package manager. Cargo packages are always installed with `--locked`. The `scripts` sub-key is for tools that ship their own curl-piped installer instead of a package-manager package; entries are `name@url`, and `name` is checked on `PATH` before running the installer.

The `npm` sub-key is for tools that ship only as an npm package. Both it and `scripts` take `universal` and per-OS lists, the same as the package-manager keys. `npm_install()` runs `npm install -g` with no prior check, so each run also updates the package. node is a work-only dependency: brew installs it from `work.darwin`, and `bootstrap()` installs nvm and the current LTS on Debian. A global npm install belongs to the node version that made it, so an `nvm install` of a new LTS drops every package under this key. Re-run `install.sh` after one.

### Homebrew tap trust

Homebrew refuses to load a formula from a third-party tap until that formula is trusted, and answers `brew install` with "Refusing to load formula ... from untrusted tap". Three taps here need it: `hashicorp/tap`, `facebook/fb`, and `atlassian/homebrew-acli`.

`homebrew/trust.json` holds the trusted entries, and `bootstrap.sh` links it to `~/.homebrew/trust.json` through `FILES_DARWIN`. Homebrew reads `$XDG_CONFIG_HOME/homebrew/trust.json` instead when that variable is set. Nothing in this repo sets it, so the link covers every machine here.

Either order works on a new machine, and the order decides how tidy the result is. README puts `install.sh` first, before any symlink exists, so `brew_trust()` in `install.sh` writes each missing entry to a real file and the install proceeds. `bootstrap.sh` then moves that file aside as a backup and links this one.

Run `bootstrap.sh` first and no backup appears. It creates `~/.homebrew` and links the file before Homebrew is installed, so the entries are already in place when the first `brew install` needs them. `brew_trust()` finds each one and writes nothing. Both of its other steps, the allowed-signers file and the nvim plugins, skip when git or nvim is missing, so running it on a machine with no packages is safe.

On a machine that is already set up, every entry is present, `brew_trust()` writes nothing, and the linked file stays untouched.

Add a formula to `homebrew/trust.json` whenever you add a tapped formula to `packages.yml`. A `brew trust` run writes through the symlink and lands in this repo, where it shows up as a change to commit.

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
2. Two identity files, included in order. `~/.gitconfig-identity` always applies. Two `includeIf` rules, `gitdir:~/scm/work/` and `gitdir:~/.agents/`, then pull in `~/.gitconfig-work-identity`, which overrides it in either tree. Git takes the last value it reads, so order in the file is what makes work win.

Identity follows the directory and nothing else. A repo outside `~/scm/work` and `~/.agents` gets the personal identity, wherever it pushes.

`gitdir:` matches the location of the `.git` directory, not the checkout. A linked worktree therefore takes the identity of its main repo, wherever the worktree sits. Agent tooling puts worktrees of `~/scm/work` repos under `~/.agents/worktrees/`, and they are work because their main repo is. The `~/.agents` rule covers repos cloned directly into `~/.agents`. Git has no condition that matches a worktree's own path.

Neither identity file is in this repo, and neither is any key. Each holds a name, an email, and the path to a signing key, and `bootstrap.sh` copies each from a template in `git/` when the destination is missing. It never overwrites one you have filled in. The `TEMPLATE_FILES` array holds the mapping.

The same key has to be registered with each forge before signatures verify: GitHub under "SSH and GPG keys" with the type "Signing key", GitLab under "SSH Keys" with the usage type "Authentication & Signing". A key added for authentication alone signs fine and verifies nowhere.

`gpg.ssh.allowedSignersFile` points at `~/.config/git/allowed_signers`, which git needs to check a signature locally. Without it, every request for a verification result fails, including the `%G?` log format and `git verify-commit`, even though the commit is signed correctly.

That file is generated, not edited. `generate_allowed_signers()` in `bootstrap.sh` rewrites it on each run from the two identity files, one line per address. An identity is skipped until its email looks like an address and its signing key is readable, so a run before you fill in the templates is harmless. Fill in an identity and re-run.

An earlier version of this config signed with OpenPGP on GitHub and SSH on GitLab, and selected between them with eight `includeIf "hasconfig:remote.*.url:..."` blocks. Signing everything with SSH replaced all of it. If you ever need the per-remote form back, know that git matches the SCP form (`git@host:group/repo.git`) and the URL form (`https://host/group/repo.git`) with different globs, `*` never crosses a `/`, and each forge therefore needs four patterns.
