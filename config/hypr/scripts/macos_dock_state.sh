#!/bin/bash
# =====================================================================
# macos_dock_state.sh
# Lanza nwg-dock-hyprland con launcher rofi y estilos macOS.
# =====================================================================

# Matar dock anterior
pkill -f 'nwg-dock-hyprland' 2>/dev/null || true
sleep 0.5

# Forzar copia de style.css por si nwg-dock-hyprland lo sobreescribió
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
if [ -f "$REPO_DIR/config/nwg-dock-hyprland/style.css" ]; then
    cp -f "$REPO_DIR/config/nwg-dock-hyprland/style.css" "$HOME/.config/nwg-dock-hyprland/style.css"
fi
if [ -f "$REPO_DIR/config/nwg-dock-hyprland/dock_launcher.sh" ]; then
    cp -f "$REPO_DIR/config/nwg-dock-hyprland/dock_launcher.sh" "$HOME/.config/nwg-dock-hyprland/dock_launcher.sh"
    chmod +x "$HOME/.config/nwg-dock-hyprland/dock_launcher.sh"
fi

# Lanzar dock con launcher rofi
nwg-dock-hyprland -i 48 -w 10 -mb 10 -lp start -c "rofi -show drun -theme $HOME/.config/rofi/launchpad.rasi" &
