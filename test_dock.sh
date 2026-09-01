#!/bin/bash
# =====================================================================
# test_dock.sh - Diagnóstico del dock
# Ejecuta esto en la VM para ver qué falla
# =====================================================================

echo "=== 1. Verificando nwg-dock-hyprland ==="
if command -v nwg-dock-hyprland &>/dev/null; then
    echo "  OK: nwg-dock-hyprland instalado"
    which nwg-dock-hyprland
else
    echo "  ERROR: nwg-dock-hyprland NO está instalado"
    echo "  Solución: sudo pacman -S nwg-dock-hyprland"
    exit 1
fi

echo ""
echo "=== 2. Verificando icono ==="
ICON="$HOME/.local/share/icons/WhiteSur-dark/actions/symbolic/view-app-grid-symbolic.svg"
if [ -f "$ICON" ]; then
    echo "  OK: Icono encontrado"
else
    echo "  WARN: Icono no encontrado - el dock funcionará sin icono"
    echo "  Buscando iconos WhiteSur..."
    find ~/.local/share/icons/ -name "*view-app-grid*" 2>/dev/null | head -3
fi

echo ""
echo "=== 3. Verificando dock_launcher.sh ==="
LAUNCHER="$HOME/.config/nwg-dock-hyprland/dock_launcher.sh"
if [ -f "$LAUNCHER" ]; then
    echo "  OK: dock_launcher.sh encontrado"
else
    echo "  WARN: dock_launcher.sh no encontrado"
fi

echo ""
echo "=== 4. Verificando style.css ==="
STYLE="$HOME/.config/nwg-dock-hyprland/style.css"
if [ -f "$STYLE" ]; then
    echo "  OK: style.css encontrado"
else
    echo "  WARN: style.css no encontrado"
fi

echo ""
echo "=== 5. Verificando Wayland ==="
if [ -n "$WAYLAND_DISPLAY" ]; then
    echo "  OK: WAYLAND_DISPLAY=$WAYLAND_DISPLAY"
else
    echo "  ERROR: WAYLAND_DISPLAY no está definido"
    echo "  Solución: Asegúrate de estar en una sesión Wayland"
fi

echo ""
echo "=== 6. Intentando lanzar dock SIN argumentos ==="
echo "  Ejecutando: nwg-dock-hyprland -i 48 -w 10 -mb 10 -lp start"
nwg-dock-hyprland -i 48 -w 10 -mb 10 -lp start 2>&1 &
DOCK_PID=$!
sleep 2

if kill -0 "$DOCK_PID" 2>/dev/null; then
    echo "  OK: Dock está corriendo PID=$DOCK_PID"
    kill "$DOCK_PID" 2>/dev/null
else
    echo "  ERROR: Dock murió inmediatamente"
    wait "$DOCK_PID" 2>/dev/null
    echo "  Código de salida: $?"
fi

echo ""
echo "=== 7. Intentando lanzar dock CON icono ==="
if [ -f "$ICON" ]; then
    echo "  Ejecutando: nwg-dock-hyprland -i 48 -w 10 -mb 10 -lp start -ico $ICON"
    nwg-dock-hyprland -i 48 -w 10 -mb 10 -lp start -ico "$ICON" 2>&1 &
    DOCK_PID=$!
    sleep 2

    if kill -0 "$DOCK_PID" 2>/dev/null; then
        echo "  OK: Dock con icono está corriendo PID=$DOCK_PID"
        kill "$DOCK_PID" 2>/dev/null
    else
        echo "  ERROR: Dock con icono murió inmediatamente"
    fi
fi

echo ""
echo "=== 8. Intentando lanzar dock CON launcher ==="
if [ -f "$LAUNCHER" ]; then
    echo "  Ejecutando: nwg-dock-hyprland -i 48 -w 10 -mb 10 -lp start -c $LAUNCHER"
    nwg-dock-hyprland -i 48 -w 10 -mb 10 -lp start -c "$LAUNCHER" 2>&1 &
    DOCK_PID=$!
    sleep 2

    if kill -0 "$DOCK_PID" 2>/dev/null; then
        echo "  OK: Dock con launcher está corriendo PID=$DOCK_PID"
        echo "  ¡DEJALO CORRER!"
    else
        echo "  ERROR: Dock con launcher murió"
    fi
fi

echo ""
echo "=== 9. Versión de nwg-dock ==="
nwg-dock-hyprland --version 2>&1 || echo "  No soporta --version"

echo ""
echo "=== DIAGNÓSTICO COMPLETADO ==="
