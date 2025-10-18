# Integrate with windows clipboard
alias pbcopy='clip.exe'
alias pbpaste='powershell.exe Get-Clipboard'

# Store SSH keys across terminal sessions
eval "$(keychain --eval --quiet id_rsa)"
