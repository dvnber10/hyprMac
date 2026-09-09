#!/bin/bash
current=$(eww get popup_open 2>/dev/null)

if [ "$current" = "calendar" ]; then
    ~/.config/eww/scripts/close_popups.sh
else
    ~/.config/eww/scripts/close_popups.sh
    eww update popup_open=calendar
    eww open click-catcher
    eww open calendar
fi