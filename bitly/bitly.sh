#!/bin/bash

set -e

###############################################################################
## Constants
###############################################################################

readonly DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
readonly SCRIPT=$(basename "${0}")


###############################################################################
## Defaults
###############################################################################

BITLY_GROUP_ID='BjckmpmygzW'

###############################################################################
## Main Function
###############################################################################

main() {
    if [ "${1}" = "help" ] || [ "${1}" = "--help" ]; then
        long_usage
        return 0
    fi

    while getopts ":hg:" o; do
        case "${o}" in
            h)
                long_usage
                return 0
                ;;
            g)
                BITLY_GROUP_ID="${OPTARG}" 
                ;;
            *)
                short_usage
                return 1
                ;;
        esac
    done
    shift $((OPTIND-1))

    link=$@

    if [ -z "${link}" ]; then
        echo -e "A link must be supplied.\n" 1>&2
        short_usage
        return 1
    fi

    if [ -z "${BITLY_OAUTH_TOKEN}" ]; then
        echo "Environment variable must be set: BITLY_OAUTH_TOKEN" >&2
        exit 1
    fi

    shorten
}

###############################################################################
## Functions
###############################################################################

short_usage() {
    echo "Usage: ${SCRIPT} [-h|--help] [-g bitly_group] link"
}

long_usage() {
    short_usage
    echo ""
    echo "${SCRIPT} shortens a link and adds the shortened version to the"
    echo "macOS clipboard in addition to priting to stdout. This script"
    echo "requires a Bitly OAUTH key to operated which must be set via the"
    echo "BITLY_OAUTH_TOKEN environment variable."
    echo ""
    echo "    Options:"
    echo "        --help | -h"
    echo "            Prints this menu"
    echo "        -g bitly_group"
    echo "            Overrides the default group. For more information see"
    echo "            the bitly API docs ()"
    echo ""
    echo "    Arguments:"
    echo "        link"
    echo "            A link to be shortened. If the link doesn't include a"
    echo "            scheme ('http://' or 'https://') then 'https://' is"
    echo "            automatically appended."
}

shorten() {
    echo "${link}" | egrep -q '^http' || link="https://${link}"

    output=$(curl -sfX POST https://api-ssl.bitly.com/v4/shorten \
        -H 'Content-Type: application/json' \
        -H "Authorization: Bearer ${BITLY_OAUTH_TOKEN}" \
        --data \
        "{\
            \"group_guid\": \"${BITLY_GROUP_ID}\", \
            \"long_url\": \"${link}\" \
         }" \
    )

    if [ $? -ne 0 ]; then
        exit 1
    else
        echo "${output}" | jq -r '.link' | tee >(tr -d '\n' | pbcopy)
    fi
}


###############################################################################
## Entry Point
###############################################################################

main "${@}"

