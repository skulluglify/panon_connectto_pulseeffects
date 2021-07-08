#! /usr/bin/env bash

function check_binaries () {

    FIND_BINARIES=$(which ${1} | grep -Eiv "^${1} not found$")

    if [ -z "$FIND_BINARIES" ]; then
        echo 1
    fi
}

##? demonize, always activate pulseeffects
while true; do
    sleep 1
    if [ -z "$(check_binaries panon_connectto_pulseeffects.sh)" ]; then
        if [ ! "$(pgrep pulseeffects)" ]; then
            panon_connectto_pulseeffects.sh
        fi
    fi
done
