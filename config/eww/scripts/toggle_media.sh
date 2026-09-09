#!/bin/sh
player=$(playerctl -l 2>/dev/null | head -n1)

if [ -n "$player" ]; then
    playerctl --player "$player" play-pause
    sleep 0.2
    eww update media_json="$($HOME/.config/eww/scripts/get_media_info.sh)"
fi
