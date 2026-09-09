#!/bin/bash
# ~/.config/eww/scripts/get_minimized_windows.sh
# Ventanas minimizadas del workspace actual (por tag)

MINIMIZED_FILE="/tmp/eww-minimized.json"
if [ ! -f "$MINIMIZED_FILE" ]; then
    echo "[]"
    exit 0
fi

# Workspace actual
CURRENT_WS=$(hyprctl activewindow -j 2>/dev/null | jq -r '.workspace.id // 1')

# Ventanas con tag "minimized" en el workspace actual
ACTIVE=$(hyprctl clients -j 2>/dev/null | jq -r --argjson ws "$CURRENT_WS" '[.[] | select(.workspace.id == $ws and (.tags | index("minimized"))) | .address]')

if [ "$ACTIVE" = "[]" ] || [ -z "$ACTIVE" ]; then
    echo "[]"
    exit 0
fi

python3 -c "
import json, sys
f = '$MINIMIZED_FILE'
active = json.loads(sys.argv[1])
try:
    data = json.load(open(f))
    result = [w for w in data if w['address'] in active][:5]
    print(json.dumps(result))
except:
    print('[]')
" "$ACTIVE" 2>/dev/null || echo "[]"
