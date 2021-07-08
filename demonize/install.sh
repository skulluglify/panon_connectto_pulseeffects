#! /usr/bin/env bash

if [ $(id -u) -eq 0 ]; then
    echo -en "\x1b[1;31;40m root is not supported for now! \x1b[0m\n" && exit 1
fi

mkdir -p $HOME/.local/bin/

cat always_activate.sh >$HOME/.local/bin/panon_connectto_pulseeffects_always_activate.sh
chmod a+x $HOME/.local/bin/panon_connectto_pulseeffects_always_activate.sh

service_demonize=`cat panon_connectto_pulseeffects.service | sed -e "s/ExecStart=/ExecStart=$(which panon_connectto_pulseeffects_always_activate.sh | tr '/' '|')/g" | tr '|' '/'`

if [ ! -f $HOME/.config/systemd/user/default.target.wants/panon_connectto_pulseeffects.service ]; then

    ##? default.target.wants
    cat <<< $service_demonize >$HOME/.config/systemd/user/default.target.wants/panon_connectto_pulseeffects.service
    chmod a+x $HOME/.config/systemd/user/default.target.wants/panon_connectto_pulseeffects.service

    cat <<< $service_demonize >$HOME/.config/systemd/user/panon_connectto_pulseeffects.service
    chmod a+x $HOME/.config/systemd/user/panon_connectto_pulseeffects.service

    systemctl --user enable panon_connectto_pulseeffects.service
    systemctl --user restart panon_connectto_pulseeffects.service
    systemctl --user daemon-reload

    echo -en "\x1b[1;32;40m installed successfully! \x1b[0m\n" && exit 1
fi

echo -en "\x1b[1;32;40m was installed! \x1b[0m\n" && exit 1
