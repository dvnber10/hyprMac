#!/bin/bash
# Daemon para monitorear y actualizar la Dynamic Island automáticamente

echo "Iniciando Dynamic Island Daemon..."

while true; do
    # Actualizar estado basado en música
    ~/.config/eww/scripts/update_island_state.sh
    
    # Verificar notificaciones
    ~/.config/eww/scripts/check_notification.sh
    
    # Esperar antes de la siguiente iteración
    sleep 1
done