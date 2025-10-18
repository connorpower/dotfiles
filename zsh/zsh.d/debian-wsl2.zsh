# Integrate with windows clipboard
alias pbcopy='clip.exe'
alias pbpaste='powershell.exe Get-Clipboard'

# Add GPG and SSH keys into persistent agents
function addkeys() {
    eval "$(keychain --eval --quiet id_rsa)"
    eval $(keychain --eval --agents gpg EC2399A673BBCD1F)
}

function wslcd() {
    newpath=$(wslpath "${1}")
    cd "${newpath}"
}
