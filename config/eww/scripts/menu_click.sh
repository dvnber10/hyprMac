#!/bin/bash
# Lee el menu activo desde la variable de EWW y lo abre
menu="$1"
if [ -n "$menu" ]; then
    ~/.config/eww/scripts/open_app_menu.sh "$menu"
fi
