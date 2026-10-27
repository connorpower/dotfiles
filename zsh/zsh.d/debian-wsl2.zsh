# WSL appends the whole Windows PATH, about 40 directories under /mnt/c, with
# duplicates. Each lookup of a missing command then scans every one of them
# over the slow drive mount, and Windows builds such as git.exe can stand in
# for a missing Linux tool. Keep only the directories that hold the Windows
# tools used from this shell:
#
#   - WINDOWS and system32: explorer.exe, clip.exe for pbcopy, cmd.exe
#   - WindowsPowerShell: powershell.exe for pbpaste
#   - the code, cursor, and zed launchers
#
# The match ignores case and the Windows user name, so it holds on any
# machine. Docker is left out: with Docker Desktop's WSL integration on, the
# docker CLI comes from /usr/bin instead.
if [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
    () {
        local dir
        local -a keep=()
        for dir in "${path[@]}"; do
            case "${${dir%/}:l}" in
                /mnt/[a-z]/windows \
                | /mnt/[a-z]/windows/system32 \
                | */windowspowershell/v1.0 \
                | */microsoft\ vs\ code/bin \
                | */cursor/resources/app/bin \
                | */zed/bin)
                    keep+=("${dir}")
                    ;;
                /mnt/[a-z]/*)
                    ;;
                *)
                    keep+=("${dir}")
                    ;;
            esac
        done
        path=("${keep[@]}")
    }
fi

# Integrate with windows clipboard
alias pbcopy='clip.exe'
alias pbpaste='powershell.exe Get-Clipboard'

function wslcd() {
    newpath=$(wslpath "${1}")
    cd "${newpath}"
}
