#!/bin/bash
# Alterna un archivo de estado y aplica la acción (ej: makoctl)
if [ -f /tmp/dnd_mode ]; then
    rm /tmp/dnd_mode
    makoctl mode -r dnd  # si usas mako
else
    touch /tmp/dnd_mode
    makoctl mode -a dnd
fi
notify-send "No molestar" "$( [ -f /tmp/dnd_mode ] && echo 'Activado' || echo 'Desactivado')"