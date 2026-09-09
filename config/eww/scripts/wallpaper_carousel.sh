#!/bin/bash
# ============================================================
# wallpaper_carousel.sh — Carrusel de wallpapers con navegación
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

# Función para mostrar el wallpaper actual
show_wallpaper() {
    local index=$1
    local file="${FILES[$index]}"
    local name=$(basename "$file")
    local total=${#FILES[@]}
    local current_marker=""
    
    if [ "$file" = "$CURRENT" ]; then
        current_marker=" [ACTUAL]"
    fi
    
    # Mostrar información
    clear
    echo "┌─────────────────────────────────────────────────────────┐"
    echo "│                  🎨 SELECTOR DE WALLPAPERS            │"
    echo "├─────────────────────────────────────────────────────────┤"
    echo "│                                                         │"
    
    # Usar kitty o terminal para mostrar la imagen
    if [ -n "$TERMINAL" ] && command -v chafa &> /dev/null; then
        # Mostrar con chafa en terminal
        chafa -s 80x40 "$file" 2>/dev/null || echo "│   (No se puede mostrar la imagen en terminal)             │"
    elif command -v tput &> /dev/null; then
        echo "│   $name$current_marker                                 │"
        echo "│   Tamaño: $(du -h "$file" | cut -f1)                    │"
        echo "│   $((index+1)) de $total                                 │"
    else
        echo "│   $name$current_marker                                 │"
        echo "│   $((index+1)) de $total                                 │"
    fi
    
    echo "│                                                         │"
    echo "├─────────────────────────────────────────────────────────┤"
    echo "│   ← → Navegar   |   Enter Seleccionar   |   q Salir   │"
    echo "└─────────────────────────────────────────────────────────┘"
}

# Encontrar el índice actual
CURRENT_INDEX=0
for i in "${!FILES[@]}"; do
    if [ "${FILES[$i]}" = "$CURRENT" ]; then
        CURRENT_INDEX=$i
        break
    fi
done

# Bucle principal
INDEX=$CURRENT_INDEX
show_wallpaper $INDEX

while true; do
    # Leer tecla
    read -rsn1 key
    
    case $key in
        $'\x1b') # ESC o flecha
            read -rsn2 -t 0.1 key2
            if [ "$key2" = "[D" ]; then
                # Flecha izquierda
                INDEX=$((INDEX - 1))
                [ $INDEX -lt 0 ] && INDEX=$((${#FILES[@]} - 1))
                show_wallpaper $INDEX
            elif [ "$key2" = "[C" ]; then
                # Flecha derecha
                INDEX=$((INDEX + 1))
                [ $INDEX -ge ${#FILES[@]} ] && INDEX=0
                show_wallpaper $INDEX
            else
                # ESC presionado
                echo "Saliendo..."
                exit 0
            fi
            ;;
        "") # Enter
            SELECTED="${FILES[$INDEX]}"
            echo "Aplicando: $(basename "$SELECTED")..."
            bash "$HOME/.config/eww/scripts/set_wallpaper.sh" "$SELECTED" "default"
            notify-send "Wallpaper" "Aplicado: $(basename "$SELECTED")"
            exit 0
            ;;
        [qQ]) # Salir
            echo "Saliendo..."
            exit 0
            ;;
    esac
done