#!/bin/bash
# ============================================================
# scan_wallpapers.sh — Escanea carpetas y retorna JSON
# Uso: scan_wallpapers.sh [carpeta]
# Si no se pasa carpeta, escanea wallpapers/images y wallpapers/videos
# ============================================================

WALLPAPER_DIR="$HOME/.config/eww/wallpapers"
FOLDER="${1:-$WALLPAPER_DIR}"
CURRENT=$(cat "$HOME/.cache/current_wallpaper" 2>/dev/null)
FAVORITES_FILE="$HOME/.config/eww/wallpapers/favorites/.list"

# Construir JSON de imágenes
build_json() {
    local dir="$1"
    local type="$2"
    echo -n "["
    local first=true

    while IFS= read -r -d '' file; do
        [ "$first" = true ] && first=false || echo -n ","
        local name=$(basename "$file")
        local fav="false"
        [ -f "$FAVORITES_FILE" ] && grep -qxF "$file" "$FAVORITES_FILE" 2>/dev/null && fav="true"
        local is_current="false"
        [ "$file" = "$CURRENT" ] && is_current="true"
        echo -n "{\"name\":\"$name\",\"path\":\"$file\",\"type\":\"$type\",\"favorite\":$fav,\"current\":$is_current}"
    done < <(find "$dir" -maxdepth 2 -type f \( \
        -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \
        -o -iname "*.webp" -o -iname "*.bmp" -o -iname "*.svg" \
        -o -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.webm" \
        -o -iname "*.mov" -o -iname "*.gif" \
    \) -print0 2>/dev/null | sort -z)

    echo -n "]"
}

build_json "$FOLDER" "all"
