#!/bin/bash
# "Ajustes del Sistema" — abre el gestor de apariencia GTK si lo
# tienes instalado (nwg-look), si no, avisa cómo instalarlo.
# Cámbialo libremente por lo que uses (ej. tu propio panel de ajustes).
if command -v nwg-look &>/dev/null; then
    nwg-look
else
    notify-send "Ajustes del Sistema" "Instala nwg-look para el panel de apariencia: sudo pacman -S nwg-look"
fi