#!/bin/bash
# Estado de batería: icono según nivel
bat=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo "100")
status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo "Discharging")

if [ "$status" = "Charging" ]; then
    echo "󰂄"
elif [ "$bat" -ge 80 ]; then
    echo "󰁹"
elif [ "$bat" -ge 60 ]; then
    echo "󰂀"
elif [ "$bat" -ge 40 ]; then
    echo "󰁾"
elif [ "$bat" -ge 20 ]; then
    echo "󰁼"
else
    echo "󰁺"
fi
