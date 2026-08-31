#!/bin/bash
# "Actualización de Software" — abre un gestor gráfico de paquetes
# si tienes alguno (pamac), si no, abre una terminal con pacman -Syu.
# Cámbialo por lo que realmente uses.
if command -v pamac-manager &>/dev/null; then
    pamac-manager
elif command -v kitty &>/dev/null; then
    kitty -e sudo pacman -Syu
else
    notify-send "Actualización de Software" "Instala pamac (AUR) para un gestor gráfico, o corre 'sudo pacman -Syu' manualmente."
fi