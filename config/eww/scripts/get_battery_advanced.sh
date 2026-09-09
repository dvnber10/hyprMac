#!/bin/bash
capacity=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n 1)
status=$(cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -n 1)

charging=false
if [ "$status" = "Charging" ]; then
    charging=true
fi

# Verde (#30d158) si carga, Azul (#0a84ff) si descarga
if [ "$charging" = true ]; then
    color="#30d158"
    icon="󰂄"
else
    color="#0a84ff"
    icon="󰁹"
fi

apps=$(ps -eo comm,%cpu --sort=-%cpu | head -n 4 | tail -n 3 | awk '{printf "{\"name\": \"%s\", \"usage\": \"%.1f%%\"},\n", $1, $2}' | sed '$ s/,$//')
apps_json="[${apps}]"

jq -n \
  --arg percent "${capacity:-100}" \
  --argjson charging "$charging" \
  --arg icon "$icon" \
  --arg color "$color" \
  --argjson apps "$apps_json" \
  '{percent: $percent, charging: $charging, icon: $icon, color: $color, apps: $apps}'