#!/bin/bash
# =====================================================================
# macos_dock_state.sh
# Lanza nwg-dock-hyprland y lo reinicia según el estado de la ventana.
# Versión robusta: funciona aunque jq o hyprctl fallen.
# =====================================================================

LOG="/tmp/nwg-dock.log"
PID_FILE="/tmp/nwg-dock.pid"

# Icono del launcher (finder icon)
ICON="$HOME/.local/share/icons/WhiteSur-dark/actions/symbolic/view-app-grid-symbolic.svg"
DOCK_SCRIPT="$HOME/.config/nwg-dock-hyprland/dock_launcher.sh"
DOCK_STYLE="$HOME/.config/nwg-dock-hyprland/style.css"

# Verificar que nwg-dock-hyprland esté instalado
if ! command -v nwg-dock-hyprland &>/dev/null; then
    echo "ERROR: nwg-dock-hyprland no está instalado" >> "$LOG"
    exit 1
fi

# Si el icono no existe, lanzar sin icono
ICON_ARG=""
if [ -f "$ICON" ]; then
    ICON_ARG="-ico $ICON"
fi

# Si el style no existe, lanzar sin style
STYLE_ARG=""
if [ -f "$DOCK_STYLE" ]; then
    STYLE_ARG="-s $DOCK_STYLE"
fi

# Si el launcher no existe, lanzar sin launcher
SCRIPT_ARG=""
if [ -f "$DOCK_SCRIPT" ]; then
    SCRIPT_ARG="-c $DOCK_SCRIPT"
fi

start_dock() {
    # Matar dock anterior si existe
    stop_dock
    sleep 0.3

    # Lanzar dock
    # shellcheck disable=SC2086
    nwg-dock-hyprland -i 48 -w 10 -mb 10 -lp start $ICON_ARG $SCRIPT_ARG $STYLE_ARG >/tmp/nwg-dock-out.log 2>&1 &
    DOCK_PID=$!
    echo "$DOCK_PID" > "$PID_FILE"
    echo "$(date) - Dock iniciado PID=$DOCK_PID" >> "$LOG"
}

stop_dock() {
    if [ -f "$PID_FILE" ]; then
        OLD_PID=$(cat "$PID_FILE")
        if [ -n "$OLD_PID" ] && kill -0 "$OLD_PID" 2>/dev/null; then
            kill "$OLD_PID" 2>/dev/null || true
        fi
        rm -f "$PID_FILE"
    fi
    pkill -f 'nwg-dock-hyprland' 2>/dev/null || true
}

get_state() {
    # Intentar obtener estado con hyprctl + jq
    if command -v hyprctl &>/dev/null && command -v jq &>/dev/null; then
        fullscreen=$(hyprctl activewindow -j 2>/dev/null | jq -r '.fullscreen // 0' 2>/dev/null)
        if [ "$fullscreen" = "1" ] || [ "$fullscreen" = "true" ]; then
            echo "fullscreen"
            return
        fi
    fi
    echo "normal"
}

# =====================================================================
# PRIMERA EJECUCIÓN: lanzar dock de inmediato
# =====================================================================
start_dock

# =====================================================================
# LOOP: solo reinicia dock si cambia el estado
# =====================================================================
last_state=""

while true; do
    current_state=$(get_state)

    if [ "$current_state" != "$last_state" ]; then
        echo "$(date) - Estado cambió: $last_state -> $current_state" >> "$LOG"
        start_dock
        last_state="$current_state"
    fi

    sleep 1
done
