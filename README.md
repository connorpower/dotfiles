# Dotfiles

These are my dotfiles common configs. They aren't intended to be useful to
anyone other than myself.

## Organization

Files are organized by topic:

- **git**: everything relating to git (aliases, configs, etc).
- **nvim**: nvim configuration and plugins.
- **zsh/rc**: primary zshrc file
- **zsh/zsh.d/***: purpose or os-specific zsh includes
- **tty**: everything related to terminal configuration (
  [Kitty](https://sw.kovidgoyal.net/kitty/)).
- **bin**: utilities of various kinds
- ... etc.

## Setup

On a fresh machine, run the two scripts **in this order**:

```sh
./packages/install.sh base        # 1. install tools (see categories below)
./bootstrap.sh                    # 2. symlink the configs into place
```

Order matters: `bootstrap.sh` only creates symlinks, but many of those configs
(bat themes, starship, kitty, nvim plugins, …) are inert or error until the
corresponding package from step 1 is installed. `install.sh` also bootstraps
Homebrew / `yq` / `rustup`, which nothing else sets up.

Re-running either script later is safe — both are idempotent.

## packages/install.sh

Installs packages via the OS package manager, plus `cargo` and `rustup`.
Packages are declared in `packages/packages.yml`, grouped into categories.

```sh
./packages/install.sh base                  # all machines
./packages/install.sh base personal         # + personal machines
./packages/install.sh base personal ditto   # + work tooling
./packages/install.sh -d base               # dry run
```

## bootstrap.sh

The `bootstrap.sh` script will install the dotfiles in their respective
locations.

If a real file (or a stale symlink) is already sitting at a destination, it is
moved aside to `<dest>.backup.<YYYYmmddHHMMSS>` before the symlink is created,
and a summary of everything moved is printed at the end. Pass `-f` to delete
those files instead of backing them up. Destinations that already point at the
right repo file are left untouched, so re-running is safe.

### Configuration

The only part of the script which needs to be changed is the `FILES` array at
the start of `bootstrap.sh`. The `FILES` array contains a mapping of
every file in the repository and the location it should be linked to, in
`destination -> repo/path` form.

```sh
declare -a FILES=(
  "${HOME}/.zshrc                       -> zsh/rc"
  "${HOME}/.config/zsh.d                -> zsh/zsh.d"
  "${HOME}/.gitconfig                   -> git/gitconfig"
  "${HOME}/.gitignore_global            -> git/gitignore_global"
  "${HOME}/.tigrc                       -> git/tigrc"
  "${HOME}/.config/nvim/init.lua        -> nvim/init.lua"
  # ... etc
)
```

OS-specific arrays (`FILES_DARWIN` / `FILES_DEBIAN` / `FILES_ARCH`,
`FILES_KITTY`) are merged in automatically for the detected OS.

### Usage

```
Usage: ./bootstrap.sh [-h|--help] [-f] [-d] [-l]
    --help | -h
        Prints this menu
    -d
        Dry run. Echoes the commands which would be executed to
        stdout but doesn't modify anything.
    -f
        Force. Deletes any file that is in the way instead of moving it
        to a timestamped .backup copy first.
    -l
        Lists the files that would be installed by this program. Each
        full path is printed on a new line making the output suitable
        for piping to xargs or using as a for-loop input, i.e:

            for file in $(./bootstrap.sh -l); do
                ls -lah "$file";
            done
```
