alias o='open .'
alias ow='open ./*.xcworkspace'

# Flush local DNS cache
alias dns_flush='sudo killall -HUP mDNSResponder; sleep 2;'

# Preview with QuickLook
alias qlf='qlmanage -p "$@" &> /dev/null'
