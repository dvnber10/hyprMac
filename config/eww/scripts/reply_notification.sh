#!/usr/bin/env bash
MSG="$1"
[[ -z "$MSG" ]] && exit 0

APP_CLASS="whatsapp"   # <- ajusta esto al class real que viste arriba

if command -v hyprctl &>/dev/null; then
  hyprctl dispatch focuswindow "class:$APP_CLASS" >/dev/null
elif command -v wmctrl &>/dev/null; then
  wmctrl -a "WhatsApp"
fi

sleep 0.3   # dale tiempo a la app a tomar el foco

if command -v wtype &>/dev/null; then          # Wayland
  wtype -- "$MSG"
  wtype -P Return -p Return
elif command -v xdotool &>/dev/null; then       # X11 (o XWayland)
  xdotool type --clearmodifiers -- "$MSG"
  xdotool key Return
fi

eww update island_state="collapsed" reply_text=""
eww close dynamic-island 2>/dev/null