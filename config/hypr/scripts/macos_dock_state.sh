#!/bin/bash

last_state=""

start_dock() {
    if [[ "$1" == "fullscreen" ]]; then
        nohup nwg-dock-hyprland -d -hd 20 -hl overlay -l overlay -p bottom -lp start -ico /home/duvan/.local/share/icons/WhiteSur-dark/actions/symbolic/view-app-grid-symbolic.svg -i 48 -w 10 -mb 10 -c /home/duvan/.config/nwg-dock-hyprland/dock_launcher.sh -s style.css >/tmp/nwg-dock.log 2>&1 &
    else
        nohup nwg-dock-hyprland -i 48 -w 10 -mb 10 -lp start -ico /home/duvan/.local/share/icons/WhiteSur-dark/actions/symbolic/view-app-grid-symbolic.svg -c /home/duvan/.config/nwg-dock-hyprland/dock_launcher.sh -s style.css >/tmp/nwg-dock.log 2>&1 &
    fi
}

stop_dock() {
    pkill -f '^nwg-dock-hyprland ' 2>/dev/null || true
}

while true; do
    fullscreen=$(hyprctl activewindow -j 2>/dev/null | jq -r '.fullscreen // 0')
    window_count=$(hyprctl clients -j 2>/dev/null | jq '[.[] | select(.workspace.id >= 0 and .workspace.name != "special:minimized")] | length')

    if [[ "$fullscreen" != "0" ]]; then
        state="fullscreen"
    elif [[ "$window_count" == "0" ]]; then
        state="desktop"
    else
        state="normal"
    fi

    if [[ "$state" != "$last_state" ]]; then
        stop_dock
        start_dock "$state"
        last_state="$state"
    fi

    sleep 0.25
done
