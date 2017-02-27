#!/bin/sh
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
    echo 'Usage: xpub [-t TTY]

  -h:    Prints this help and exits.
  -v:    Prints the version and exits.
  -t:    Prints the logged user and its display environment variables
         from a graphical-session TTY or from the current one if no argument.'
}

version() {
    echo 'Xpub 0.5

Copyright (C) 2016 Thomas "Ventto" Venries.

License MIT: <https://opensource.org/licenses/MIT>.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.'
}

main () {
    isXWayland=false
    tFlag=false

    while getopts "hvt:" opt; do
        case "$opt" in
            t)  OPTARG=$(echo "${OPTARG}" | tr '[:upper:]' '[:lower:]')
                if ! printf '%s' "${OPTARG}" | grep -E '^tty[0-9]$' > /dev/null; then
                    usage ; exit 2
                fi
                tArg="${OPTARG}"
                tFlag=true     ;;
            h)  usage   ; exit ;;
            v)  version ; exit ;;
            \?) usage   ; exit ;;
            :)  usage   ; exit ;;
        esac
    done

    shift $((OPTIND - 1))

    if [ "$(id -u)" != "0" ]; then
        echo 'Run it with sudo.'
        exit 1
    fi

    ${tFlag} && xtty="${tArg}" || xtty="$(cat /sys/class/tty/tty0/active)"

    xuser=$(who | grep "${xtty}" | head -n 1 | cut -d' ' -f1)

    if [ -z "${xuser}" ]; then
        echo "No user found from ${xtty}." 1>&2
        exit 1
    fi

    xpids=$(ps -A | grep 'Xorg' | awk '{print $1}')
    vterm="vt$(printf '%s' "${xtty}" | sed -e 's/tty//g')"

    if [ -n "${xpids}" ]; then
        for xpid in "${xpids}"; do
            xdisplay=$(ps -o cmd ${xpid} | grep "${vterm}" | \
                grep -o ':[0-9]' | head -n 1)
            [ "$?" -eq 0 ] && break
        done
    fi

    if [ -z "${xdisplay}" ]; then
        #Trying to get the active display from XWayland
        xways=$(ps -A -o tty= -o pid= -o cmd= | grep Xwayland | grep -v 'grep')

        if [ -z "${xways}" ]; then
            echo "No X or XWayland process found from ${xtty}."
            exit 1
        fi

        for xway in "${xways}"; do
            echo "${xway}"
            if echo "${xway}" | grep -E "^${xtty}" > /dev/null ; then
                xdisplay=$(echo "${xway}" | awk '{print $4}')
                break
            fi
        done

        [ -z "${xdisplay}" ] && { echo 'Can not find DISPLAY.'; exit 1; }

        isXWayland=true
    fi

    for pid in $(ps -u "${xuser}" -o pid=) ; do
        env="/proc/${pid}/environ"
        display=$(cat "${env}" | tr '\0' '\n' | grep -E '^DISPLAY=' | cut -d= -f2)

        if [ -z "${display}" ] || [ "${display}" != "${xdisplay}" ]; then
            continue
        fi

        dbus=$(cat "${env}" | tr '\0' '\n' | grep -E '^DBUS_SESSION_BUS_ADDRESS=')

        if [ -n "${dbus}" ]; then
            ! $isXWayland && xauth=$(cat "${env}" | tr '\0' '\n' | grep -E '^XAUTHORITY=')
            break
        fi
    done

    if [ -z "${dbus}" ]; then
        echo 'No session bus address found.' 1>&2
        exit 1
    fi

    # XWayland does not need Xauthority
    if ! $isXWayland && [ -z "${xauth}" ] ; then
        echo 'No Xauthority found.' 1>&2
        exit 1
    fi


    ! $tFlag && { echo  "TTY=${xtty}"; echo "XUSER=${xuser}"; } || echo "XUSER=${xuser}"
    ! $isXWayland && echo "${xauth}"

    echo "DISPLAY=${xdisplay}"
    echo "${dbus}"
}

main "$@"
