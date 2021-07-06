#! /usr/bin/env bash

if [ $(id -u) -eq 0 ]; then
    cp -r "panon_connectto_pulseeffects.sh" "/usr/local/sbin/"
    cp -r "panon_connectto_pulseeffects.desktop" "/etc/xdg/autostart/"
    chmod a+x "/usr/local/sbin/panon_connectto_pulseeffects.sh"
    chmod a+x "/etc/xdg/autostart/panon_connectto_pulseeffects.desktop"
    exit 1
fi

cp -r "panon_connectto_pulseeffects.sh" "$HOME/.local/bin/"
cp -r "panon_connectto_pulseeffects.desktop" "$HOME/.config/autostart/"
chmod a+x "$HOME/.local/bin/panon_connectto_pulseeffects.sh"
chmod a+x "$HOME/.config/autostart/panon_connectto_pulseeffects.desktop"
exit 1
