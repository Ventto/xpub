Xpub
====

[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://github.com/Ventto/xpub/blob/master/LICENSE)

*"Xpub is a Shell script to get user's display environment variables of any X graphical session from anywhere."*

## Perks

* [x] **No requirement**: near POSIX compliance.
* [x] **No more script**: run graphical tasks directly from udev rules.
* [x] **Painless**: do not care about correctly setting display environment variables.
* [x] **Useful**: *export* it and run GUI tasks from CLI as root.

# Installation

* Package (AUR)

```bash
$ yaourt -S xpub
```

* Manually

```bash
$ git clone https://github.com/Ventto/xpub.git
$ cd xpub
$ chmod +x src/xpub.sh
```

# Usage

```
Usage: xpub [OPTION]...

  -h:   Prints this help and exits.
  -v:   Prints the version and exits.
  -t:   Prints the logged user and its display environment variables from a graphical-session TTY
        or from the current one if no argument.
```

# Examples

```bash
$ xpub
TTY=tty1
XUSER=user1
XAUTHORITY=/home/user1/.Xauthority    (not printed if XWayland)
DISPLAY=:0
DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1022/bus
```

### From Udev rules :

```bash
IMPORT{program}="/usr/bin/xpub", \
RUN+="/bin/su $env{XUSER} -c '/usr/bin/notify-send Hello'"
```

After editing your rules, you may need to run `udevadm control --reload-rules`.

### From command-line as *root* :

```bash
$ export $(xpub) ; su "${XUSER}" -c 'notify-send Hello'
```

### From Shell scripts :

```bash
xenv=$(xpub 2>/tmp/xpub.log)

if [ $# -ne 0 ]; then
    exit 1
else
    export ${xenv}
fi

su "${XUSER}" -c "notify-send Hello"
```
