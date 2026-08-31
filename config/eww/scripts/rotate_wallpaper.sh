#!/bin/bash
# ============================================================
# rotate_wallpaper.sh — Rota wallpapers cada X segundos
# Uso: rotate_wallpaper.sh [intervalo_en_segundos]
# Detener: pkill -f rotate_wallpaper.sh
# ============================================================

INTERVAL="${1:-300}"
WALLPAPER_DIR="$HOME/.config/eww/wallpapers/images"
PID_FILE="$HOME/.cache/wallpaper-rotation.pid"

# Si ya está corriendo, detenerlo
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    kill "$OLD_PID" 2>/dev/null
    rm -f "$PID_FILE"
    echo "Rotación detenida"
    exit 0
fi

(
    while true; do
        WALLPAPER=$(find "$WALLPAPER_DIR" -maxdepth 2 -type f \( \
            -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \
            -o -iname "*.webp" \
        \) -print0 2>/dev/null | shuf -z -n1)

        if [ -n "$WALLPAPER" ]; then
            # Usar el script set_wallpaper con fade
            bash "$HOME/.config/eww/scripts/set_wallpaper.sh" "$WALLPAPER" "fade"
            echo "$WALLPAPER" > "$HOME/.cache/current_wallpaper"
        fi

        sleep "$INTERVAL"
    done
) &

echo $! > "$PID_FILE"
echo "Rotación cada ${INTERVAL}s activa (PID: $(cat "$PID_FILE"))"
