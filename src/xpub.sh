#!/usr/bin/env bash
#
# The MIT License (MIT)
#
# Copyright (c) 2015-2016 Thomas "Ventto" Venriès <thomas.venries@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
usage() {
    echo -e "Usage: xpub [-t TTY]

  -h:\tPrints this help and exits.
  -v:\tPrints the version and exits.
  -t:\tPrints the x display environment variables from a given TTY
     \tor from the current one if no argument."
}

version() {
    echo -e "Xpub 0.2b

Copyright (C) 2016 Thomas \"Ventto\" Venries.

License MIT: <https://opensource.org/licenses/MIT>.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT."
}

main () {
    local isXWayland=false
    local tFlag=false
    local tArg

    OPTIND=1
    while getopts "hvt:" opt; do
        case "$opt" in
            t)  OPTARG=$(echo "${OPTARG}" | tr '[:upper:]' '[:lower:]')
                ! [[ "${OPTARG}" =~ ^tty[0-9]$ ]] && usage && exit 2
                tArg="${OPTARG}"
                tFlag=true ;;
            h)  usage   && exit ;;
            v)  version && exit ;;
            \?) usage   && exit ;;
            :)  usage   && exit ;;
        esac
    done

    if [ "$(id -u)" != "0" ]; then
        echo "Run it with sudo."
        exit 1
    fi

    ${tFlag} && xtty="${tArg}" || xtty="$(cat /sys/class/tty/tty0/active)"

    xuser=$(who | grep "${xtty}" | head -n 1 | cut -d ' ' -f 1)

    if [ -z "${xuser}" ]; then
        echo "No user found from ${xtty}." 1>&2
        exit 1
    fi

    xpids=$(pgrep Xorg)

    if [ -n "${xpids}" ]; then
        xdisplay=$(ps -o command -p "${xpids}" | \
            grep " vt${xtty:3:${#tty}}" | grep -o ":[0-9]" | head -n 1)
    fi


    if [ -z "${xdisplay}" ]; then
        #Trying to get the active display from XWayland
        xdisplay=$(pgrep -a Xwayland | cut -d" " -f3)
        if [ -z "${xdisplay}" ]; then
            echo "No X or XWayland process found from ${xtty}." 1>&2
            exit 1
        else
            isXWayland=true
        fi
    fi

    for pid in $(ps -u "${xuser}" -o pid --no-headers) ; do
        env="/proc/${pid}/environ"
        display=$(grep -z "^DISPLAY=" "${env}" | tr -d '\0' | cut -d '=' -f 2)
        if [ -n "${display}" ]; then
            dbus=$(grep -z "DBUS_SESSION_BUS_ADDRESS=" "${env}" | tr -d '\0' | \
                sed 's/DBUS_SESSION_BUS_ADDRESS=//g')
            if [ -n "${dbus}" ]; then
                xauth=$(grep -z "XAUTHORITY=" "${env}" | tr -d '\0' | \
                    sed 's/XAUTHORITY=//g')
                break
            fi
        fi
    done

    if [ -z "${dbus}" ]; then
        echo "No session bus address found." 1>&2
        exit 1
    # XWayland does not need Xauthority
    elif [ -z "${xauth}" ] && [ -n "$xpids" ]; then
        echo "No Xauthority found." 1>&2
        exit 1
    fi


    ! $tFlag && echo -e "TTY=${xtty}\nXUSER=${xuser}" || echo "XUSER=${xuser}"
    ! $isXWayland && echo "XAUTHORITY=${xauth}"

    echo -e "DISPLAY=${display}\nDBUS_SESSION_BUS_ADDRESS=${dbus}"
}

main "$@"
