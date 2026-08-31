#!/bin/bash
# Devuelve JSON: {"title":"...", "artist":"...", "playing":true/false}
if ! command -v playerctl &>/dev/null || [ -z "$(playerctl -l 2>/dev/null)" ]; then
    echo '{"title":"","artist":"","playing":false}'
    exit 0
fi

title=$(playerctl metadata title 2>/dev/null | sed 's/"/\\"/g')
artist=$(playerctl metadata artist 2>/dev/null | sed 's/"/\\"/g')
status=$(playerctl status 2>/dev/null)
playing=false
[ "$status" = "Playing" ] && playing=true

echo "{\"title\":\"$title\",\"artist\":\"$artist\",\"playing\":$playing}"