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

## bootstrap.sh

The `bootstrap.sh` script will install the dotfiles in their respective
locations.

### Configuration

The only part of the script which needs to be changed is the `FILES` array at
the start of `bootstrap.sh`. The `FILES` array contains a mapping of
every file in the repository and the location it should be linked to.

```sh
declare -a FILES=(
    'zsh/rc               -> ~/.zshrc'
    'zsh/zsh.d            -> ~/.config/zsh.d'
    'git/gitconfig        -> ~/.gitconfig'
    'git/gitignore_global -> ~/.gitignore_global'
    'git/tigrc            -> ~/.tigrc'
    'nvim/init.lua        -> ~/.config/nvim/init.lua'
    # ... etc
)
```

### Usage

```
Usage: ./bootstrap.sh [-h|--help] [-f] [-d] [-l]
    --help | -h
        Prints this menu
    -d
        Dry run. Echoes the commands which would be executed to
        stdout but doesn't modify anything.
    -f
        Force. Overwrites any existing files.
    -l
        Lists the files that would be installed by this program. Each
        full path is printed on a new line making the output suitable
        for piping to xargs or using as a for-loop input, i.e:

            for file in $(./bootstrap.sh -l); do
                ls -lah "$file";
            done
```

