#!/bin/bash
# =====================================================================
# macos_dock_state.sh
# Lanza nwg-dock-hyprland.
# Usa solo parámetros básicos que funcionan siempre.
# =====================================================================

LOG="/tmp/nwg-dock.log"

if ! command -v nwg-dock-hyprland &>/dev/null; then
    echo "$(date) ERROR: nwg-dock-hyprland no está instalado" >> "$LOG"
    exit 1
fi

# Matar dock anterior
pkill -f 'nwg-dock-hyprland' 2>/dev/null || true
sleep 0.5

# Icono
ICON="$HOME/.local/share/icons/WhiteSur-dark/actions/symbolic/view-app-grid-symbolic.svg"

# Construir con solo lo que funciona
CMD=(nwg-dock-hyprland -i 48 -w 10 -mb 10 -lp start)

if [ -f "$ICON" ]; then
    CMD+=(-ico "$ICON")
fi

echo "$(date) Ejecutando: ${CMD[*]}" >> "$LOG"

"${CMD[@]}" >/tmp/nwg-dock-out.log 2>&1 &
DOCK_PID=$!

sleep 1

if kill -0 "$DOCK_PID" 2>/dev/null; then
    echo "$(date) OK: Dock corriendo PID=$DOCK_PID" >> "$LOG"
else
    echo "$(date) FAIL: Dock murió" >> "$LOG"
    cat /tmp/nwg-dock-out.log >> "$LOG"
fi
