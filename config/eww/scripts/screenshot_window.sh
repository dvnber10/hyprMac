#!/bin/bash
# Toma un screenshot de una ventana específica y lo guarda como miniatura
# Para ventanas en workspaces especiales, usa la geometría registrada
# Uso: screenshot_window.sh <address>
# Devuelve la ruta del thumbnail generado

ADDR="$1"
OUT_DIR="/tmp/eww-minimized-thumbs"
OUT_FILE="${OUT_DIR}/${ADDR}_thumb.png"

mkdir -p "$OUT_DIR"

# Si ya existe, no regenerar (ahorra CPU)
if [ -f "$OUT_FILE" ]; then
    echo "$OUT_FILE"
    exit 0
fi

# Obtener geometría de la ventana
WIN_JSON=$(hyprctl clients -j | jq -r --arg addr "$ADDR" '.[] | select(.address == $addr)')
if [ -z "$WIN_JSON" ]; then
    echo ""
    exit 0
fi

X=$(echo "$WIN_JSON" | jq -r '.at[0]')
Y=$(echo "$WIN_JSON" | jq -r '.at[1]')
W=$(echo "$WIN_JSON" | jq -r '.size[0]')
H=$(echo "$WIN_JSON" | jq -r '.size[1]')

# Si la geometría es 0 (ventana en workspace especial oculto),
# usar un screenshot por defecto con la clase de la ventana
if [ "$W" -le 0 ] || [ "$H" -le 0 ]; then
    # No se puede hacer screenshot de ventana oculta
    echo ""
    exit 0
fi

# Tomar screenshot de esa región
FULL_SHOT="${OUT_DIR}/${ADDR}.png"
grim -g "${X},${Y} ${W}x${H}" "$FULL_SHOT" 2>/dev/null

if [ -s "$FULL_SHOT" ]; then
    # Escalar a tamaño de miniatura (120x75) manteniendo relación de aspecto
    ffmpeg -y -i "$FULL_SHOT" -vf "scale=120:75:force_original_aspect_ratio=decrease,pad=120:75:(ow-iw)/2:(oh-ih)/2:color=0x00000000" "$OUT_FILE" 2>/dev/null
    rm -f "$FULL_SHOT"
    if [ -s "$OUT_FILE" ]; then
        echo "$OUT_FILE"
    else
        echo ""
    fi
else
    echo ""
fi
