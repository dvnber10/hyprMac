#!/bin/bash
current=$(eww get popup_open 2>/dev/null)

if [ "$current" = "apple-menu" ]; then
    ~/.config/eww/scripts/close_popups.sh
else
    ~/.config/eww/scripts/close_popups.sh
    eww update popup_open=apple-menu
    eww open click-catcher
    eww open apple-menu
fi