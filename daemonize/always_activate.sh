#! /usr/bin/env bash

function check_binaries () {

    FIND_BINARIES=$(which ${1} | grep -Eiv "^${1} not found$")

    if [ -z "$FIND_BINARIES" ]; then
        echo -en "\x1b[1;31;40m ${1} not found! \x1b[0m\n" && exit 1
    fi
}

check_binaries pgrep
check_binaries panon_connectto_pulseeffects.sh
check_binaries sleep

##? demonize, always activate pulseeffects
while true; do
    sleep 1
    if [ ! "$(pgrep pulseeffects)" ]; then
        panon_connectto_pulseeffects.sh
    fi
done
