#!/bin/bash
# Devuelve: nombre de app
class=$(hyprctl activewindow -j 2>/dev/null | jq -r '.class // ""')

case "$class" in
    kitty)          echo "Terminal" ;;
    firefox|firefox-esr|Floorp) echo "Firefox" ;;
    code|code-oss)  echo "Visual Studio Code" ;;
    dolphin)        echo "Finder" ;;
    Thunar|pcmanfm|nautilus) echo "Finder" ;;
   "")             echo "Finder" ;;
    *)              echo "$class" ;;
esac
