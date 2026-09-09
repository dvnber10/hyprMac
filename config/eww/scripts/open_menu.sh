#!/bin/bash
set -u

menu=${1:-}

case "$menu" in
    Archivo) window="menu-global-archivo" ;;
    Edición) window="menu-global-edicion" ;;
    Selección) window="menu-global-seleccion" ;;
    Ver) window="menu-global-ver" ;;
    Historial) window="menu-global-historial" ;;
    Marcadores) window="menu-global-marcadores" ;;
    Herramientas) window="menu-global-herramientas" ;;
    Terminal) window="menu-global-terminal" ;;
    Ir) window="menu-global-ir" ;;
    Ejecutar) window="menu-global-ejecutar" ;;
    Ventana) window="menu-global-ventana" ;;
    Ayuda) window="menu-global-ayuda" ;;
    *) exit 0 ;;
esac

current=$(eww get popup_open 2>/dev/null || true)
if [ "$current" = "$window" ]; then
    ~/.config/eww/scripts/close_popups.sh
    exit 0
fi

~/.config/eww/scripts/close_popups.sh
eww update active_menu="$menu"
eww update popup_open="$window"
eww open click-catcher
eww open "$window"
