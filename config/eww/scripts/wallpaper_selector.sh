#!/bin/bash
# ============================================================
# wallpaper_selector.sh — Wrapper para selector de wallpapers
# ============================================================

# Opciones
echo "Selecciona el modo:"
echo "1) Carrusel en terminal (con imágenes)"
echo "2) Carrusel con rofi"
echo "3) Selector normal con rofi"
echo "4) Salir"

read -p "Opción: " option

case $option in
    1)
        bash "$HOME/.config/eww/scripts/wallpaper_carousel.sh"
        ;;
    2)
        bash "$HOME/.config/eww/scripts/wallpaper_picker.sh"
        ;;
    3)
        # Tu script original
        bash "$HOME/.config/eww/scripts/wallpaper_picker_original.sh"
        ;;
    *)
        exit 0
        ;;
esac