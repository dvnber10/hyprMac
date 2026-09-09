#!/bin/bash
# Abre el menú de la app activa enviando el atajo de teclado
# Uso: open_app_menu.sh "Archivo"

# Si no se pasa argumento, leer del archivo temporal
if [ -n "$1" ]; then
    menu="$1"
else
    menu=$(cat /tmp/eww_active_menu 2>/dev/null)
fi

case "$menu" in
    Archivo)      wtype -M alt "f" ;;
    Edición)      wtype -M alt "e" ;;
    Ver)          wtype -M alt "v" ;;
    Historial)    wtype -M alt "h" ;;
    Marcadores)   wtype -M alt "b" ;;
    Herramientas) wtype -M alt "t" ;;
    Selección)    wtype -M alt "s" ;;
    Terminal)     wtype -M alt "t" ;;
    Ir)           wtype -M alt "g" ;;
    Ventana)      wtype -M alt "w" ;;
    Ayuda)        wtype -M alt "shift" "h" ;;
    *)            wtype -M alt "$(echo "$menu" | head -c1)" ;;
esac
