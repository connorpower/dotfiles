date_iso_8601() {
    if [[ ! -z "${1}" ]]; then
        # Expects input in form of `date +%s`
        date -u -r "${1}" +%Y-%m-%dT%H:%M:%SZ
    else
        date -u +%Y-%m-%dT%H:%M:%SZ
    fi
}
