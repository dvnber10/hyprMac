#!/bin/bash
if [ "$(nmcli radio wifi)" = "disabled" ]; then
    echo "Desactivado"
    exit 0
fi
ssid=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)
[ -z "$ssid" ] && echo "Sin conexión" || echo "$ssid"