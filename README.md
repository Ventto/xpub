
Xpub
===================
[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://github.com/Ventto/xpub/blob/master/LICENSE)
[![Version](https://img.shields.io/badge/version-0.2b-orange.svg?style=flat)](https://github.com/Ventto/xpub)
[![Language (Bash)](https://img.shields.io/badge/powered_by-Bash-brightgreen.svg)](https://www.gnu.org/software/bash)

*"Xpub is a Bash script to get X display environment's variables from anywhere"*

*"The purpose is to help displaying GUI from anywhere even from limited environment as privileged user (ex: udev rules)."*

# Installation

* Package

```
$ yaourt -S xpub
```

* Manually

```
$ git clone https://github.com/Ventto/xpub.git
$ cd xpub
$ chmod +x src/xpub.sh
```

# Usage

```
Usage: xpub [OPTION]...

  -h:   Prints this help and exits.
  -v:   Prints the version and exits.
  -t:   Prints the x display environment variables from a given TTY
        or from the current one if no argument.
```

# Examples

```
$ pub
TTY=tty1
XUSER=user1
XAUTHORITY=/home/user1/.Xauthority
DISPLAY=:0
DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1022/bus
```

### Uses *xpub* in an Udev rule :

```bash
xenv=$(xpub 2>/tmp/xpub.log)

[ $# -ne 0 ] && exit 1 || export ${xenv}

su -m ${XUSER} -c "<command>"
```

### Or if you prefer only exporting the essentials:

```bash
xenv=$(xpub 2>/tmp/xpub.log)

[ $# -ne 0 ] && exit 1 || export ${xenv}

DBUS_SESSION_BUS_ADDRESS=${DBUS_SESSION_BUS_ADDRESS} \
DISPLAY=${DISPLAY} XAUTHORITY=${XAUTHORITY} \
su ${XUSER} -c "<command>"
```

