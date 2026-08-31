#!/bin/bash
# ============================================================
# wallpaper_picker.sh — Selector de wallpapers con rofi
# ============================================================

WALLPAPER_DIR="$HOME/.config/eww/wallpapers"
CURRENT=$(cat "$HOME/.cache/current_wallpaper" 2>/dev/null)

# Recolectar todos los wallpapers
FILES=()
while IFS= read -r -d '' file; do
    FILES+=("$file")
done < <(find "$WALLPAPER_DIR" -maxdepth 2 -type f \( \
    -iname "*.jpg" -o \
    -iname "*.jpeg" -o \
    -iname "*.png" -o \
    -iname "*.webp" -o \
    -iname "*.bmp" -o \
    -iname "*.mp4" -o \
    -iname "*.mkv" -o \
    -iname "*.webm" -o \
    -iname "*.mov" -o \
    -iname "*.gif" \
\) -print0 2>/dev/null | sort -z)

if [ ${#FILES[@]} -eq 0 ]; then
    notify-send "Wallpapers" "No se encontraron wallpapers en $WALLPAPER_DIR"
    exit 0
fi

# Construir entrada de rofi
ENTRIES=""
for file in "${FILES[@]}"; do
    name=$(basename "$file")
    if [ "$file" = "$CURRENT" ]; then
        ENTRIES+="● $name\n"
    else
        ENTRIES+="  $name\n"
    fi
done

# Lanzar rofi
CHOSEN=$(echo -e "$ENTRIES" | rofi -dmenu -i -p "Wallpaper" \
    -theme "$HOME/.config/rofi/wallpaper.rasi")

if [ -z "$CHOSEN" ]; then
    exit 0
fi

# Limpiar el nombre
SELECTED_NAME=$(echo "$CHOSEN" | sed 's/^[[:space:]]*●[[:space:]]*//' | sed 's/^[[:space:]]*//')

# Encontrar la ruta completa
SELECTED=""
for file in "${FILES[@]}"; do
    if [ "$(basename "$file")" = "$SELECTED_NAME" ]; then
        SELECTED="$file"
        break
    fi
done

if [ -n "$SELECTED" ]; then
    bash "$HOME/.config/eww/scripts/set_wallpaper.sh" "$SELECTED" "default"
    notify-send "Wallpaper" "Aplicado: $SELECTED_NAME"
fi
