#!/bin/bash
# =====================================================================
# macos_dock_state.sh
# Lanza nwg-dock-hyprland con estilos macOS.
# nwg-dock-hyprland carga automáticamente style.css desde:
#   ~/.config/nwg-dock-hyprland/style.css
# =====================================================================

# Matar dock anterior si existe
pkill -f 'nwg-dock-hyprland' 2>/dev/null || true
sleep 0.5

# Lanzar dock - simplemente así de simple
nwg-dock-hyprland -i 48 -w 10 -mb 10 -lp start &
