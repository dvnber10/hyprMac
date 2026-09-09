#!/bin/sh
status=$(/home/duvan/.config/eww/scripts/get_bt_status.sh)

case "$status" in
    Desactivado) icon="󰂲" ;;
    *) icon="󰂯" ;;
esac

printf '{"text":"%s","tooltip":"Bluetooth: %s"}\n' "$icon" "$status"
