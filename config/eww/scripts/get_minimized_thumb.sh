#!/bin/bash
# Devuelve la ruta del thumbnail de la N-esima ventana minimizada del workspace actual
# Uso: get_minimized_thumb.sh <index>

INDEX="${1:-0}"
EMPTY="/tmp/eww-minimized-thumbs/empty.png"

# Obtener workspace actual (usar activeworkspace, NO activewindow)
WS=$(hyprctl activeworkspace -j 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])" 2>/dev/null)
WS="${WS:-0}"

ADDR=$(python3 -c "
import json, sys
try:
    with open('/home/duvan/.config/eww/minimized/minimized.json') as f:
        data = json.load(f)
    filtered = [w for w in data if w.get('workspace') == $WS]
    if $INDEX < len(filtered):
        print(filtered[$INDEX].get('address', ''))
except:
    pass
" 2>/dev/null)

THUMB_DIR="/tmp/eww-minimized-thumbs"
if [ -n "$ADDR" ] && [ -f "$THUMB_DIR/${ADDR}_thumb.png" ]; then
    echo "$THUMB_DIR/${ADDR}_thumb.png"
else
    echo "$EMPTY"
fi
