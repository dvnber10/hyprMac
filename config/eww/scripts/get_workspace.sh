#!/bin/bash
# Devuelve el workspace actual (para que Eww pueda reaccionar a cambios)
CURRENT_WS=$(hyprctl activeworkindow -j 2>/dev/null | jq -r '.workspace.id')
if [ -z "$CURRENT_WS" ] || [ "$CURRENT_WS" = "null" ]; then
    echo "1"
else
    echo "$CURRENT_WS"
fi
