#!/bin/bash
# ~/.config/hypr/scripts/macos_minimize.sh
#
# Hyprland no tiene "minimizar" real (no hay barra de tareas nativa).
# Esto manda la ventana a un workspace especial oculto, que es el
# equivalente más cercano. Para "restaurarla" usa tu dock (nwg-dock)
# o el bind SUPER+M que puedes agregar para reabrir el especial:
#   hyprctl dispatch togglespecialworkspace minimized

ADDR=$(hyprctl activewindow -j | jq -r '.address')
if [ -z "$ADDR" ] || [ "$ADDR" = "null" ]; then
    exit 0
fi

hyprctl dispatch "hl.dsp.window.move({ workspace = 'special:minimized' })"
pkill -RTMIN+8 waybar 2>/dev/null