#!/bin/bash
# ~/.config/eww/scripts/restore_window.sh
# Restaura una ventana minimizada: opacidad + clear tags + enfocar

ADDR="$1"
[ -z "$ADDR" ] && exit 0

MINIMIZED_FILE="/home/duvan/.config/eww/minimized/minimized.json"
THUMB_DIR="/tmp/eww-minimized-thumbs"



# Verificar que la ventana realmente existe
EXISTS=$(hyprctl clients -j 2>/dev/null | jq -r --arg a "$ADDR" '[.[] | select(.address == $a)] | length')
if [ "$EXISTS" = "0" ]; then
    # Ventana ya no existe, solo limpiar JSON
    python3 -c "
import json
f = '$MINIMIZED_FILE'
try:
    data = json.load(open(f))
    data = [w for w in data if w.get('address') != '$ADDR']
    json.dump(data, open(f,'w'), indent=2)
except: pass
"
    rm -f "${THUMB_DIR}/${ADDR}.png" "${THUMB_DIR}/${ADDR}_thumb.png" 2>/dev/null
    exit 0
fi
# Limpiar datos stale primero
bash ~/.config/eww/scripts/cleanup_minimized.sh 2>/dev/null

# Restaurar opacidad
hyprctl eval "hl.dispatch(hl.dsp.window.set_prop({prop='opacity', value='1 1', window = 'address:${ADDR}'}))"

# Quitar tag minimized
hyprctl eval "hl.dispatch(hl.dsp.window.clear_tags({window = 'address:${ADDR}'}))"

sleep 0.1

# Enfocar la ventana restaurada
hyprctl eval "hl.dispatch(hl.dsp.focus({window = 'address:${ADDR}'}))"

# Limpiar JSON
python3 -c "
import json
f = '$MINIMIZED_FILE'
try:
    data = json.load(open(f))
    data = [w for w in data if w.get('address') != '$ADDR']
    json.dump(data, open(f,'w'), indent=2)
except: pass
"

# Limpiar thumbnails
rm -f "${THUMB_DIR}/${ADDR}.png" "${THUMB_DIR}/${ADDR}_thumb.png" 2>/dev/null
