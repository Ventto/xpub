Xpub
===================
[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://github.com/Ventto/xpub/blob/master/LICENSE)
[![Version](https://img.shields.io/badge/version-0.1-orange.svg?style=flat)](https://github.com/Ventto/xpub)
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

# Example

```
$ pub
TTY=tty1
XUSER=user1
XAUTHORITY=/home/user1/.Xauthority
DISPLAY=:0
DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1022/bus
```
