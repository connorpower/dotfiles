source "${HOME}/.config/zsh.d/linux.zsh"

# Fix cursor size in QT apps
export XCURSOR_SIZE=24

alias kboff='light -S 0 -s sysfs/leds/tpacpi::kbd_backlight'
alias kbon='light -S 50 -s sysfs/leds/tpacpi::kbd_backlight'

function suspend-then-hibernate() {
    swaylock -f
    sleep 2
    sudo systemctl suspend-then-hibernate
}

function hibernate() {
    swaylock -f
    sleep 2
    sudo systemctl hibernate
}

function shot() {
    grim -g "$(slurp)" "${HOME}/Desktop/$(date_iso_8601).png"
}

alias zth='zathura'
