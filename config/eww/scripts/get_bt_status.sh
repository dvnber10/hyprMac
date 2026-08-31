#!/bin/bash
if ! command -v bluetoothctl &>/dev/null; then
    echo "No disponible"
    exit 0
fi
if bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
    connected=$(bluetoothctl devices Connected 2>/dev/null | head -n1 | cut -d' ' -f3-)
    [ -n "$connected" ] && echo "$connected" || echo "Activado"
else
    echo "Desactivado"
fi