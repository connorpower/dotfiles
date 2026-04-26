# Integrate with windows clipboard
alias pbcopy='clip.exe'
alias pbpaste='powershell.exe Get-Clipboard'

function wslcd() {
    newpath=$(wslpath "${1}")
    cd "${newpath}"
}
