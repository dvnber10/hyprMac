#!/bin/bash
# Script para iniciar la Dynamic Island con eww

# Asegurarse de que eww esté corriendo
if ! pgrep -x "eww" > /dev/null; then
    eww daemon &
    sleep 1
fi

# Abrir la ventana de la dynamic island
eww open dynamic-island

# Iniciar el daemon de monitoreo de notificaciones
~/.config/eww/scripts/dynamic_island_daemon.sh &

echo "Dynamic Island iniciada"