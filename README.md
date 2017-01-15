Xpub
===================
[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://github.com/Ventto/xpub/blob/master/LICENSE)
[![Status](https://img.shields.io/badge/status-experimental-orange.svg?style=flat)](https://github.com/Ventto/xpub)
[![Language (Bash)](https://img.shields.io/badge/powered_by-Bash-brightgreen.svg)](https://www.gnu.org/software/bash)

*"Xpub is a Bash script to get X variables environment even from limited env as privileged user."*

The purpose is to give X variables environment for tools which want to execute GUI from limited environment as privileged user (ex: udev rules).
# Installation

*"Installation as AUR package, soon."*

```
$ git clone https://github.com/Ventto/xpub.git
$ cd xpub
$ chmod +x src/xpub.sh
$ ./src/xpub.sh 
```

# Usage

```
Usage: xpub [OPTION]...

Information:
  none:	Prints X environment based on the current tty
  -t:	Prints X environment based on a given TTY
  
Miscellaneous:
  -h:	Prints this help and exits
  -v:	Prints version and exits
```

# Examples

* Gets X user environment based on the current TTY:

```
$ pub 
TTY=tty1
XUSER=user1
XAUTHORITY=/home/user1/.Xauthority
DISPLAY=:0
DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1022/bus
```


* Gets X user environment based on a given TTY:

```
$ xpub -t tty3
XUSER=user2
XAUTHORITY=/home/user2/.Xauthority
DISPLAY=:1
DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1024/bus
```





