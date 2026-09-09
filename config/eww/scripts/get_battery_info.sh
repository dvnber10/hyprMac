#!/bin/bash
# Obtiene los datos de la primera batería disponible
capacity=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n 1)
status=$(cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -n 1)

# Determina si está cargando (booleano true/false para Eww)
charging=false
if [ "$status" = "Charging" ]; then
    charging=true
fi

# Iconos limpios según el nivel y estado
if [ "$charging" = true ]; then
    icon="󰂄"
elif [ "$capacity" -gt 90 ]; then
    icon="󰁹"
elif [ "$capacity" -gt 70 ]; then
    icon="󰂂"
elif [ "$capacity" -gt 50 ]; then
    icon="󰁿"
elif [ "$capacity" -gt 30 ]; then
    icon="󰁽"
else
    icon="󰁻"
fi

# Salida en formato JSON limpio
jq -n \
  --arg percent "${capacity:-100}" \
  --argjson charging "$charging" \
  --arg icon "$icon" \
  '{percent: $percent, charging: $charging, icon: $icon}'