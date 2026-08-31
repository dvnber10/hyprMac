#!/bin/bash
# ~/.config/hypr/scripts/macos_fullscreen.sh
#
# Emula el botón verde de macOS: no "maximiza" la ventana en su sitio,
# crea un Escritorio (Space) nuevo y pone la ventana ahí en pantalla
# pantalla completa, ocultando Waybar mientras el Space está activo. Requiere 'jq'.

ADDR=$(hyprctl activewindow -j | jq -r '.address')
if [ -z "$ADDR" ] || [ "$ADDR" = "null" ]; then
    exit 0
fi

IS_FULLSCREEN=$(hyprctl activewindow -j | jq -r '.fullscreen')
if [ "$IS_FULLSCREEN" != "0" ]; then
    hyprctl dispatch 'hl.dsp.window.fullscreen()'
    hyprctl keyword plugin:hyprbars:enabled true
    exit 0
fi

# En fullscreen real no deben existir botones flotando sobre la aplicación.
hyprctl keyword plugin:hyprbars:enabled false

# Busca el número de workspace más alto en uso ahora mismo y usa el siguiente
MAX_WS=$(hyprctl workspaces -j | jq '[.[].id | select(. > 0)] | if length == 0 then 0 else max end')
NEW_WS=$((MAX_WS + 1))

hyprctl dispatch "hl.dsp.window.move({ workspace = $NEW_WS })"
hyprctl dispatch "hl.dsp.focus({ workspace = $NEW_WS })"
hyprctl dispatch 'hl.dsp.window.fullscreen()'