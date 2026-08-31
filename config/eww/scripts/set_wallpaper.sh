#!/bin/bash
WALLPAPER="$1"
[ -z "$WALLPAPER" ] && exit 1
[ ! -f "$WALLPAPER" ] && exit 1
echo "$WALLPAPER" > "$HOME/.cache/current_wallpaper"
/usr/bin/awww img "$WALLPAPER"
