#!/bin/bash
# ============================================================
# toggle_wallpapers.sh — Abrir/cerrar el carrusel de wallpapers
# ============================================================

WIN="wallpaper-carousel"

if eww active-windows 2>/dev/null | grep -q "$WIN"; then
    eww close "$WIN"
else
    # Pre-cargar datos y abrir
    bash ~/.config/eww/scripts/wp_nav.sh init
    eww open "$WIN"
fi
