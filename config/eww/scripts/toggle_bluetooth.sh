#!/bin/bash
if bluetoothctl show | grep -q "Powered: yes"; then
    bluetoothctl power off
else
    bluetoothctl power on
fi
notify-send "Bluetooth" "$(bluetoothctl show | grep -q 'Powered: yes' && echo 'Activado' || echo 'Desactivado')"