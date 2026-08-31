#!/bin/bash
# Alterna el estado de Wi-Fi (activa/desactiva)
if nmcli radio wifi | grep -q "enabled"; then
    nmcli radio wifi off
else
    nmcli radio wifi on
fi
# Opcional: notificar
notify-send "Wi-Fi" "$(nmcli radio wifi | grep -q enabled && echo 'Activado' || echo 'Desactivado')"