#!/bin/bash
# ============================================================
# toogle_wallpaper_picker.sh — Abre/cierra el selector de wallpapers
# ============================================================

current=$(cat /tmp/eww_popup_open 2>/dev/null)
eww_state=$(eww active-windows 2>/dev/null)

if echo "$eww_state" | grep -q "wallpaper-picker"; then
    eww close wallpaper-picker 2>/dev/null
    eww close click-catcher 2>/dev/null
    eww update popup_open=none
else
    # Cerrar otros popups primero
    eww close control-center 2>/dev/null
    eww close apple-menu 2>/dev/null

    # Escanear wallpapers
    wallpapers=$(bash ~/.config/eww/scripts/scan_wallpapers.sh)
    eww update wallpaper_list="$wallpapers"

    # Abrir
    eww update popup_open=wallpaper-picker
    eww open click-catcher
    eww open wallpaper-picker
fi
