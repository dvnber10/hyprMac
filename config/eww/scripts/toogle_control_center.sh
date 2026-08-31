#!/bin/bash
current=$(eww get popup_open 2>/dev/null)

if [ "$current" = "control-center" ]; then
    ~/.config/eww/scripts/close_popups.sh
else
    ~/.config/eww/scripts/close_popups.sh
    eww update popup_open=control-center
    eww update cc_view=main
    eww open click-catcher
    eww open control-center
fi