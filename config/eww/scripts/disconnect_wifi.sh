#!/bin/bash
# Desconecta de la red Wi-Fi activa actual usando NetworkManager
active_conn=$(nmcli -t -f NAME,TYPE connection show --active | grep "wireless" | cut -d: -f1)
if [ -n "$active_conn" ]; then
    nmcli connection down "$active_conn"
else
    # Alternativa genérica si nmcli device disconnect es preferible
    device=$(nmcli dev | grep wifi | awk '{print $1}')
    [ -n "$device" ] && nmcli dev disconnect "$device"
fi