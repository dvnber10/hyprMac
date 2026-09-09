#!/bin/bash
# ~/.config/eww/scripts/cleanup_minimized.sh
# Limpia el minimized.json eliminando entradas de ventanas que ya no existen.
# Se puede llamar periódicamente o antes de cada lectura.

MINIMIZED_FILE="/home/duvan/.config/eww/minimized/minimized.json"
THUMB_DIR="/tmp/eww-minimized-thumbs"

[ ! -f "$MINIMIZED_FILE" ] && exit 0

# Obtener todas las direcciones de ventanas que existen actualmente
EXISTING=$(hyprctl clients -j 2>/dev/null | jq -r '.[].address' 2>/dev/null)

python3 -c "
import json, os, sys

f = '$MINIMIZED_FILE'
existing_str = '''$EXISTING'''
existing = set(l.strip() for l in existing_str.splitlines() if l.strip())

try:
    data = json.load(open(f))
except:
    data = []

original_len = len(data)

# Mantener solo ventanas que siguen existiendo
cleaned = [w for w in data if w.get('address') in existing]

if len(cleaned) != original_len:
    json.dump(cleaned, open(f, 'w'), indent=2)
    # Limpiar thumbnails huérfanos
    kept_addrs = set(w['address'] for w in cleaned)
    thumb_dir = '$THUMB_DIR'
    if os.path.isdir(thumb_dir):
        for fname in os.listdir(thumb_dir):
            if fname.endswith('_thumb.png'):
                addr = fname.replace('_thumb.png', '')
                if addr not in kept_addrs:
                    os.remove(os.path.join(thumb_dir, fname))
" 2>/dev/null
