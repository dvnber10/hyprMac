#!/bin/bash
# ~/.config/hypr/scripts/macos_minimize.sh
# Minimiza la ventana activa: tag + opacity 0 + screenshot + JSON
# Botón amarillo de hyprbars / SUPER+M

# Limpiar datos stale primero
bash ~/.config/eww/scripts/cleanup_minimized.sh 2>/dev/null

WIN_JSON=$(hyprctl activewindow -j)
[ -z "$WIN_JSON" ] && exit 0

ADDR=$(echo "$WIN_JSON" | jq -r '.address')
[ -z "$ADDR" ] || [ "$ADDR" = "null" ] && exit 0

# No minimizar si ya tiene tag minimized
TAGS=$(echo "$WIN_JSON" | jq -r '.tags[]? // empty' | grep -c "minimized")
[ "$TAGS" -gt 0 ] && exit 0

WS_ID=$(echo "$WIN_JSON" | jq -r '.workspace.id')
[ -z "$WS_ID" ] || [ "$WS_ID" = "null" ] && exit 0

TITLE=$(echo "$WIN_JSON" | jq -r '.title // ""')
WIN_CLASS=$(echo "$WIN_JSON" | jq -r '.class // ""')

# Registrar en JSON
MINIMIZED_FILE="/home/duvan/.config/eww/minimized/minimized.json"
python3 -c "
import json, os
f = '$MINIMIZED_FILE'
data = []
if os.path.exists(f):
    try: data = json.load(open(f))
    except: pass
# Evitar duplicados
if not any(w['address'] == '$ADDR' for w in data):
    data.append({'address':'$ADDR','workspace':int('$WS_ID'),'title':'''$TITLE''','class':'$WIN_CLASS'})
    json.dump(data, open(f,'w'), indent=2)
"

# Screenshot antes de ocultar
THUMB_DIR="/tmp/eww-minimized-thumbs"
mkdir -p "$THUMB_DIR"
X=$(echo "$WIN_JSON" | jq -r '.at[0]')
Y=$(echo "$WIN_JSON" | jq -r '.at[1]')
W=$(echo "$WIN_JSON" | jq -r '.size[0]')
H=$(echo "$WIN_JSON" | jq -r '.size[1]')
[ "$W" -gt 0 ] 2>/dev/null && [ "$H" -gt 0 ] 2>/dev/null && timeout 3 grim -g "${X},${Y} ${W}x${H}" "${THUMB_DIR}/${ADDR}.png" 2>/dev/null
[ -s "${THUMB_DIR}/${ADDR}.png" ] 2>/dev/null && timeout 3 ffmpeg -y -i "${THUMB_DIR}/${ADDR}.png" -vf "scale=120:75" "${THUMB_DIR}/${ADDR}_thumb.png" 2>/dev/null
rm -f "${THUMB_DIR}/${ADDR}.png" 2>/dev/null

# Tag como minimized (la window rule oculta automáticamente)
hyprctl eval "hl.dispatch(hl.dsp.window.tag({tag = 'minimized', window = 'address:${ADDR}'}))"

# Hacer invisible
hyprctl eval "hl.dispatch(hl.dsp.window.set_prop({prop='opacity', value='0 0', window = 'address:${ADDR}'}))"

# Foco en la siguiente ventana visible (no minimizada), MISMO workspace
sleep 0.2
VISIBLE=$(hyprctl clients -j 2>/dev/null | jq -r --argjson ws "$WS_ID" '
    [.[] | select(.workspace.id == $ws)
     | select(.tags | index("minimized") | not)
     | select(.mapped == true)
     | select(.address != "'"$ADDR"'")]
    | .[0].address // empty')
[ -n "$VISIBLE" ] && hyprctl eval "hl.dispatch(hl.dsp.focus({window = 'address:${VISIBLE}'}))"
