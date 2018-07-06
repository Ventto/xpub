Xpub
====

[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://github.com/Ventto/xpub/blob/master/LICENSE)
[![Vote for xpub](https://img.shields.io/badge/AUR-Vote_for-yellow.svg)](https://aur.archlinux.org/packages/xpub/)

*"Xpub is a Shell script to get user's display environment variables of any X graphical session from anywhere."*

## Perks

* [x] **No requirement**: POSIX-compliant.
* [x] **Omniscient**: Provides X environment variables of any session from any user.
* [x] **Usefull**: Run graphical commands from udevrules (see below).
* [x] **Extra**: Display graphical command on a specific session.
* [x] **Support**: XWayland users, keep calm.

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
Usage: xpub [-t TTY]

Without option, prints the X session information of the current user.

  -h:   Prints this help and exits.
  -v:   Prints the version and exits.
  -t:   prints the current TTY's user X session information.
```

# Examples


### From terminal

*sudo* is required.

* Get information of your current session:

```bash
$ xpub
TTY=tty2
XUSER=alice
XAUTHORITY=/home/alice/.Xauthority
DISPLAY=:0
DBUS_SESSION_BUS_ADDRESS=/path
```

* Get information of a specific session:

```bash
$ xpub -t tty2
XUSER=alice
XAUTHORITY=/home/alice/.Xauthority
DISPLAY=:0
DBUS_SESSION_BUS_ADDRESS=/path
```

### Udev rules

```python
IMPORT{program}="/usr/bin/xpub", \
RUN+="/bin/su $env{XUSER} -c '/usr/bin/notify-send Hello'"
```

After editing your rules, you may need to run `udevadm control --reload-rules`.

### For *root* 

```bash
$ export $(xpub) ; su "${XUSER}" -c '/usr/bin/notify-send Hello'
```

### Shell scripts

```bash
xenv=$(xpub 2>/tmp/xpub.log)

if [ $# -ne 0 ]; then
    exit 1
else
    export ${xenv}
fi

su "${XUSER}" -c "/usr/bin/notify-send Hello"
```
