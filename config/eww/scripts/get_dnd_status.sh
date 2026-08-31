#!/bin/bash
# Simula No molestar (puedes usar mako, dunst, etc.)
# Si usas mako, revisa el modo de no molestar con "makoctl mode"
if [ -f /tmp/dnd_mode ]; then
    echo "Activado"
else
    echo "Desactivado"
fi