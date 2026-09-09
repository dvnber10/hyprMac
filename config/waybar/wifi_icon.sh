#!/bin/sh
status=$(/home/duvan/.config/eww/scripts/get_wifi_status.sh)

case "$status" in
    Desactivado) icon="󰤭" ;;
    "Sin conexión") icon="󰤯" ;;
    *) icon="󰤨" ;;
esac

printf '{"text":"%s","tooltip":"Wi-Fi: %s"}\n' "$icon" "$status"
