#!/bin/bash
current=$(eww get popup_open 2>/dev/null)

if [ "$current" = "menu-ventana" ]; then
    ~/.config/eww/scripts/close_popups.sh
else
    ~/.config/eww/scripts/close_popups.sh
    eww update popup_open=menu-ventana
    eww open click-catcher
    eww open menu-ventana
fi
