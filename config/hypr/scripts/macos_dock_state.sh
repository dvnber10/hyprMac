#!/bin/bash
# =====================================================================
# macos_dock_state.sh
# Lanza nwg-dock-hyprland con estilos macOS.
# =====================================================================

LOG="/tmp/nwg-dock.log"

# Verificar que nwg-dock-hyprland esté instalado
if ! command -v nwg-dock-hyprland &>/dev/null; then
    echo "$(date) ERROR: nwg-dock-hyprland no está instalado" >> "$LOG"
    exit 1
fi

# Matar dock anterior si existe
pkill -f 'nwg-dock-hyprland' 2>/dev/null || true
sleep 0.5

# Icono del launcher
ICON="$HOME/.local/share/icons/WhiteSur-dark/actions/symbolic/view-app-grid-symbolic.svg"
LAUNCHER="$HOME/.config/nwg-dock-hyprland/dock_launcher.sh"
STYLE="$HOME/.config/nwg-dock-hyprland/style.css"

# Expandir HOME (en caso de que eval no lo haga)
HOME_EXPANDED="$HOME"

# Usar array para evitar problemas de expansión
CMD=(nwg-dock-hyprland -i 48 -w 10 -mb 10 -lp start)

if [ -f "$ICON" ]; then
    CMD+=(-ico "$ICON")
fi

if [ -f "$STYLE" ]; then
    CMD+=(-s "$STYLE")
fi

if [ -f "$LAUNCHER" ]; then
    CMD+=(-c "$LAUNCHER")
fi

echo "$(date) Ejecutando: ${CMD[*]}" >> "$LOG"

# Lanzar dock
"${CMD[@]}" >/tmp/nwg-dock-out.log 2>&1 &
DOCK_PID=$!

sleep 1

if kill -0 "$DOCK_PID" 2>/dev/null; then
    echo "$(date) OK: Dock corriendo PID=$DOCK_PID" >> "$LOG"
else
    echo "$(date) FAIL: Dock murió, reintentando sin launcher..." >> "$LOG"
    # Reintentar sin launcher
    nwg-dock-hyprland -i 48 -w 10 -mb 10 -lp start >/tmp/nwg-dock-out.log 2>&1 &
    DOCK_PID=$!
    sleep 1
    if kill -0 "$DOCK_PID" 2>/dev/null; then
        echo "$(date) OK: Dock sin launcher corriendo PID=$DOCK_PID" >> "$LOG"
    else
        echo "$(date) FAIL: Dock sin launcher también murió" >> "$LOG"
        cat /tmp/nwg-dock-out.log >> "$LOG"
    fi
fi
