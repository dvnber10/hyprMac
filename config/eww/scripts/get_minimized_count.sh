#!/bin/bash
# Cuenta ventanas minimizadas del workspace actual

WS=$(hyprctl activeworkspace -j 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])" 2>/dev/null)
WS="${WS:-1}"

python3 -c "
import json
try:
    with open('/home/duvan/.config/eww/minimized/minimized.json') as f:
        data = json.load(f)
    print(len([w for w in data if w.get('workspace') == $WS]))
except:
    print(0)
"
