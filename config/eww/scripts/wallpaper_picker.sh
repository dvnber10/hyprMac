#!/bin/bash
# ============================================================
# wallpaper_picker.sh — Selector de wallpapers con rofi (Carrusel)
# ============================================================

WALLPAPER_DIR="$HOME/.config/eww/wallpapers"
CURRENT=$(cat "$HOME/.cache/current_wallpaper" 2>/dev/null)

# Crear directorio temporal para thumbnails
THUMB_DIR="/tmp/rofi_wallpapers"
mkdir -p "$THUMB_DIR"

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

# Función para generar thumbnail
generate_thumbnail() {
    local file="$1"
    local hash=$(echo "$file" | md5sum | cut -d' ' -f1)
    local thumb_path="$THUMB_DIR/${hash}.jpg"
    
    # Si el thumbnail ya existe y es más reciente que el original, usarlo
    if [ -f "$thumb_path" ] && [ "$thumb_path" -nt "$file" ]; then
        echo "$thumb_path"
        return
    fi
    
    # Generar thumbnail según el tipo de archivo
    case "$file" in
        *.mp4|*.mkv|*.webm|*.mov)
            # Para videos, extraer frame
            ffmpeg -i "$file" -vf "scale=800:450:force_original_aspect_ratio=decrease,pad=800:450:(ow-iw)/2:(oh-ih)/2" \
                -vframes 1 -update 1 "$thumb_path" 2>/dev/null
            ;;
        *.gif)
            # Para GIFs, tomar el primer frame
            convert "$file[0]" -resize 800x450^ -gravity center -extent 800x450 "$thumb_path" 2>/dev/null
            ;;
        *)
            # Para imágenes normales
            convert "$file" -resize 800x450^ -gravity center -extent 800x450 "$thumb_path" 2>/dev/null
            ;;
    esac
    
    echo "$thumb_path"
}

# Construir entrada de rofi
ENTRIES=""
for file in "${FILES[@]}"; do
    name=$(basename "$file")
    thumb=$(generate_thumbnail "$file")
    
    # Marcar el actual
    marker=" "
    if [ "$file" = "$CURRENT" ]; then
        marker="●"
    fi
    
    # Crear entrada con icono
    ENTRIES+="$marker $name\x00icon\x1f$thumb\n"
done

# Crear archivo de tema temporal para rofi
TEMP_THEME="/tmp/rofi_wallpaper_theme.rasi"
cat > "$TEMP_THEME" << 'EOF'
configuration {
    show-icons: true;
    hover-select: true;
    me-select-entry: "MouseSecondary";
    me-accept-entry: "MousePrimary";
}

* {
    bg-base: rgba(20, 20, 25, 0.92);
    bg-alt: rgba(255, 255, 255, 0.06);
    bg-selected: rgba(10, 132, 255, 0.25);
    fg-main: #f3f3f3;
    fg-muted: #8e8e93;
    accent: #0a84ff;
    
    background-color: transparent;
    text-color: @fg-main;
}

window {
    transparency: "real";
    width: 900px;
    height: 650px;
    background-color: @bg-base;
    border: 1px;
    border-color: rgba(255, 255, 255, 0.08);
    border-radius: 20px;
    padding: 25px;
    location: center;
    anchor: center;
}

mainbox {
    spacing: 16px;
    children: [ inputbar, listview, message ];
}

inputbar {
    background-color: @bg-alt;
    padding: 10px 16px;
    border-radius: 12px;
    border: 1px;
    border-color: rgba(255, 255, 255, 0.06);
    children: [ prompt, entry ];
}

prompt {
    text-color: @fg-muted;
    font: "sans-serif 16";
    padding: 0px 8px 0px 0px;
    content: "🎨";
}

entry {
    placeholder: "Buscar wallpaper...";
    placeholder-color: @fg-muted;
    text-color: @fg-main;
    font: "sans-serif 13";
}

listview {
    columns: 1;
    lines: 1;
    cycle: true;
    dynamic: true;
    layout: vertical;
    spacing: 0px;
    scrollbar: false;
}

element {
    orientation: vertical;
    padding: 0px;
    background-color: transparent;
    cursor: pointer;
    border-radius: 12px;
}

element normal.normal {
    background-color: transparent;
}

element alternate.normal {
    background-color: transparent;
}

element selected.normal {
    background-color: @bg-selected;
    border: 2px;
    border-color: @accent;
    border-radius: 16px;
    padding: 5px;
}

element-icon {
    size: 500px;
    border-radius: 12px;
    margin: 0px;
    background-color: rgba(255, 255, 255, 0.03);
    padding: 0px;
}

element-text {
    font: "sans-serif 12";
    text-color: @fg-muted;
    horizontal-alignment: 0.5;
    padding: 8px 0px 0px 0px;
}

message {
    background-color: @bg-alt;
    padding: 8px 12px;
    border-radius: 8px;
    margin: 4px 0px 0px 0px;
}

message text {
    text-color: @fg-muted;
    font: "sans-serif 10";
    horizontal-alignment: 0.5;
    content: "← → Navegar | Enter Seleccionar | Esc Salir";
}
EOF

# Encontrar el índice del wallpaper actual
CURRENT_INDEX=0
for i in "${!FILES[@]}"; do
    if [ "${FILES[$i]}" = "$CURRENT" ]; then
        CURRENT_INDEX=$i
        break
    fi
done

# Lanzar rofi
CHOSEN=$(echo -e "$ENTRIES" | rofi -dmenu -i -p "" \
    -theme "$TEMP_THEME" \
    -selected-row $CURRENT_INDEX)

# Limpiar tema temporal
rm -f "$TEMP_THEME"

if [ -z "$CHOSEN" ]; then
    # Limpiar thumbnails viejos (más de 1 día)
    find "$THUMB_DIR" -type f -mtime +1 -delete 2>/dev/null
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

# Limpiar thumbnails viejos
find "$THUMB_DIR" -type f -mtime +1 -delete 2>/dev/null