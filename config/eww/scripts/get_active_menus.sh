#!/bin/bash
# Devuelve los menús separados por |
class=$(hyprctl activewindow -j 2>/dev/null | jq -r '.class // ""')

case "$class" in
    kitty)          echo "Archivo|Edición|Ver|Ventana|Ayuda" ;;
    firefox|firefox-esr|Floorp) echo "Archivo|Edición|Ver|Historial|Marcadores|Herramientas|Ventana|Ayuda" ;;
    code|code-oss)  echo "Archivo|Edición|Selección|Ver|Ir|Ejecutar|Terminal|Ayuda" ;;
    dolphin)        echo "Archivo|Edición|Ver|Ir|Ventana|Ayuda" ;;
    *)              echo "Archivo|Edición|Ver|Ventana|Ayuda" ;;
esac
