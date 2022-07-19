alias o='open .'
alias ow='open ./*.xcworkspace'

# Flush local DNS cache
alias dns_flush='sudo killall -HUP mDNSResponder; sleep 2;'

# Preview with QuickLook
function qlf() {
    qlmanage -p "$@" &> /dev/null
}

# monitor brightness control
function mon() {
    ddcctl -d 1 -b "${1}" > /dev/null
}

