#!/bin/bash
# ============================================================
# toggle_favorite.sh — Agrega/quita un wallpaper de favoritos
# Uso: toggle_favorite.sh <ruta_del_wallpaper>
# ============================================================

WALLPAPER="$1"
FAVORITES_FILE="$HOME/.config/eww/wallpapers/favorites/.list"

if [ -z "$WALLPAPER" ]; then
    exit 1
fi

mkdir -p "$(dirname "$FAVORITES_FILE")"

if [ -f "$FAVORITES_FILE" ] && grep -qxF "$WALLPAPER" "$FAVORITES_FILE"; then
    # Quitar de favoritos
    sed -i "\|^${WALLPAPER}$|d" "$FAVORITES_FILE"
    echo "removed"
else
    # Agregar a favoritos
    echo "$WALLPAPER" >> "$FAVORITES_FILE"
    echo "added"
fi
