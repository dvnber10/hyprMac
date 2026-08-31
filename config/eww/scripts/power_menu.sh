#!/bin/bash
# Muestra un menú de apagado (puedes usar wofi, dmenu, etc.)
CHOICE=$(printf "Apagar\nReiniciar\nSuspender\nCancelar" | wofi --dmenu -p "Sistema")
case "$CHOICE" in
    "Apagar") systemctl poweroff ;;
    "Reiniciar") systemctl reboot ;;
    "Suspender") systemctl suspend ;;
    *) exit 0 ;;
esac