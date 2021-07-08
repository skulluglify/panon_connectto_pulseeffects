#! /usr/bin/env bash

function check_binaries () {

    FIND_BINARIES=$(which ${1} | grep -Eiv "^${1} not found$")

    if [ -z "$FIND_BINARIES" ]; then
        echo -en "\x1b[1;31;40m ${1} not found! \x1b[0m\n" && exit 1
    fi
}

check_binaries pacmd
check_binaries pulseeffects
check_binaries pulseaudio
##? .local/share/plasma/plasmoids/panon

##? DEBUG LOG 
echo "STARTED INJECTION ..." | tee $HOME/.Panon_ConnectTo_PulseEffects_Debug.txt

##? DAEMONIZE SUPPORT  
if [ "$(systemctl --user list-unit-files | grep -i 'panon_connectto_pulseeffects')" ]; then
    if [ "$(systemctl --user status panon_connectto_pulseeffects.service | head -n 3 | tail -n 1 | grep -i 'active: inactive (dead)')" ]; then
        ##? DEBUG LOG 
        echo "RESTART DAEMONIZE SERVICE" | tee -a $HOME/.Panon_ConnectTo_PulseEffects_Debug.txt
        systemctl --user restart panon_connectto_pulseeffects
    fi
fi

function get_panon_index () {

    echo `pacmd list-source-outputs | grep -iB18 'application.name = "panon"' | head -n 1 | awk '{print $2}'`
}

function check_panon_connected_to_pulseeffects () {

    echo `pacmd list-source-outputs | grep -iB18 'application.name = "panon"' | head -n 5 | tail -n 1 | rev | awk '{print $1}' | rev | grep -i 'pulseeffects_apps.monitor'`
}

##? GLOBAL_VARIABLES
PULSE_EFFECTS_ACTIVATE=0

function main () {

    MAX_TIMEOUT=20

    while true; do

        if [ $MAX_TIMEOUT -eq 0 ]; then
            break
        fi

        PANON_INDEX=$(get_panon_index)

        if [ "$PANON_INDEX" ]; then
            if [ $PULSE_EFFECTS_ACTIVATE -eq 0 -o -z "$(pgrep pulseeffects)" ]; then
                PULSE_EFFECTS_ACTIVATE=1 && pulseeffects &
                ##? DEBUG LOG 
                echo "OPEN PulseEffects" | tee -a $HOME/.Panon_ConnectTo_PulseEffects_Debug.txt
            fi
            # sleep 2
            ERROR_MESSAGE=`pacmd move-source-output $PANON_INDEX PulseEffects_apps.monitor`
            if [ -n "$(echo $ERROR_MESSAGE | grep -Eiv '(failed to parse|no source found by this name or) index')" ]; then
                ##? DEBUG LOG 
                echo "FAILED SWITCH AUDIO SOURCE" | tee -a $HOME/.Panon_ConnectTo_PulseEffects_Debug.txt
            else
                ##? DEBUG LOG 
                echo "SWITCH AUDIO SOURCE" | tee -a $HOME/.Panon_ConnectTo_PulseEffects_Debug.txt
                break
            fi
        fi

        MAX_TIMEOUT=$(($MAX_TIMEOUT - 1))
        sleep .5
    done
}

##? MAIN 
main 
##? CALLBACK 24 TIMES
for x in {1..24}; do 

    CHECK_PANON_CONNECTED=$(check_panon_connected_to_pulseeffects)

    if [ "$CHECK_PANON_CONNECTED" ]; then
        ##? DEBUG LOG 
        echo "CALLBACK $x TIMES" | tee -a $HOME/.Panon_ConnectTo_PulseEffects_Debug.txt
        break
    fi

    sleep 1 
    main 
done

##? DEBUG LOG 
echo "EXITING INJECTION ..." | tee -a $HOME/.Panon_ConnectTo_PulseEffects_Debug.txt
