#!/bin/bash
eww_cmd="eww -c $HOME/.config/eww"
target_window="${1:-control-center}"

# Lista de todas las ventanas posibles del centro de control
windows=("control-center" "wifi-menu" "wifi-qr-menu" "bluetooth-menu" "audio-menu" "battery-menu")

# Verificamos si la ventana solicitada ya está abierta
if $eww_cmd active-windows | grep -q "$target_window"; then
    # Si ya está abierta, la cerramos junto con el click-catcher (efecto toggle de cierre)
    $eww_cmd close "$target_window" 2>/dev/null || true
    $eww_cmd close click-catcher 2>/dev/null || true
else
    # Si está cerrada, primero cerramos cualquier otra ventana o residuo por seguridad
    for win in "${windows[@]}"; do
        $eww_cmd close "$win" 2>/dev/null || true
    done
    
    # Abrimos el click-catcher de fondo y la ventana solicitada encima
    $eww_cmd open click-catcher
    $eww_cmd open "$target_window"
fi