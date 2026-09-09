#!/bin/bash
# Script para abrir el centro de notificaciones de swaync

# Cerrar la dynamic island si está expandida
eww update island_state=collapsed

# Abrir el centro de notificaciones de swaync
swaync-client -t -s  # Toggle notification center

# Alternativa: si swaync no tiene toggle, usar:
# swaync-client -rs  # Show notification center