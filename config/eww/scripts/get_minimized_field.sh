#!/bin/bash
# Devuelve un campo de la N-esima ventana minimizada del workspace actual
# Uso: get_minimized_field.sh <index> <field>
# field: address, title, thumb

INDEX="${1:-0}"
FIELD="${2:-title}"

EMPTY="/tmp/eww-minimized-thumbs/empty.png"
MINIMIZED_FILE="/home/duvan/.config/eww/minimized/minimized.json"

# Obtener workspace actual (activeworkspace, NO activewindow)
WS=$(hyprctl activeworkspace -j 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])" 2>/dev/null)
WS="${WS:-0}"

# Obtener campo del JSON
ADDR=$(python3 -c "
import json
try:
    with open('$MINIMIZED_FILE') as f:
        data = json.load(f)
    filtered = [w for w in data if w.get('workspace') == $WS]
    if $INDEX < len(filtered):
        if '$FIELD' == 'thumb':
            print(filtered[$INDEX].get('address', ''))
        else:
            print(filtered[$INDEX].get('$FIELD', ''))
except:
    pass
" 2>/dev/null)

if [ "$FIELD" = "thumb" ]; then
    THUMB_DIR="/tmp/eww-minimized-thumbs"
    if [ -n "$ADDR" ] && [ -f "$THUMB_DIR/${ADDR}_thumb.png" ]; then
        echo "$THUMB_DIR/${ADDR}_thumb.png"
    else
        echo "$EMPTY"
    fi
else
    if [ -n "$ADDR" ]; then
        echo "$ADDR"
    else
        echo ""
    fi
fi
