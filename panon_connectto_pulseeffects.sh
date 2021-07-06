#! /usr/bin/env bash

function check_binaries () {
    FIND_BINARIES=$(which ${1} | grep -Eiv "^${1} not found$")
    if [ -z "$FIND_BINARIES" ]; then
        echo -en "\x1b[1;31;40m ${1} not found! \x1b[0m\n" && exit 1
    fi
}

check_binaries pacmd
check_binaries pulseeffects

function get_panon_index () {
	echo `pacmd list-source-outputs | grep -iB18 'application.name = "panon"' | head -n 1 | awk '{print $2}'`
}

MAX_TIMEOUT=60
PULSE_ACTIVATE=0

while true; do
    PANON_INDEX=$(get_panon_index)
    if [ "$PANON_INDEX" ]; then
        if [ $PULSE_ACTIVATE -eq 0 -o -z "$(pgrep pulseeffects)" ]; then
            PULSE_ACTIVATE=1 && pulseeffects &
        fi
        ERROR_MESSAGE=`pacmd move-source-output $PANON_INDEX PulseEffects_apps.monitor`
        if [ -z "$(echo $ERROR_MESSAGE | grep -Eiv '(failed to parse|no source found by this name or) index')" ]; then
            break
        fi
    fi
    sleep .5
done
