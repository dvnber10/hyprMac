#!/bin/sh

wofi_menu() {
    wofi --dmenu --prompt "$1" --cache-file /dev/null --insensitive
}

if [ "${1:-}" = "--settings" ]; then
    if command -v blueman-manager >/dev/null 2>&1; then
        blueman-manager >/dev/null 2>&1 &
    else
        notify-send "Bluetooth" "Instala blueman para abrir la configuración"
    fi
    exit 0
fi

if bluetoothctl show 2>/dev/null | grep -q 'Powered: yes'; then
    toggle="󰂲  Desactivar Bluetooth"
else
    toggle="󰂯  Activar Bluetooth"
fi

choice=$(printf '%s\n󰂯  Buscar dispositivos\n󰐕  Abrir configuración Bluetooth\n' "$toggle" | wofi_menu "Bluetooth")

case "$choice" in
    *"Desactivar Bluetooth")
        bluetoothctl power off
        ;;
    *"Activar Bluetooth")
        bluetoothctl power on
        ;;
    *"Abrir configuración"*)
        if command -v blueman-manager >/dev/null 2>&1; then
            blueman-manager >/dev/null 2>&1 &
        else
            notify-send "Bluetooth" "Instala blueman para abrir la configuración"
        fi
        ;;
    *"Buscar dispositivos"*)
        bluetoothctl power on >/dev/null 2>&1
        bluetoothctl scan on >/dev/null 2>&1 &
        scan_pid=$!
        sleep 5
        kill "$scan_pid" 2>/dev/null || true
        bluetoothctl scan off >/dev/null 2>&1
        devices=$(bluetoothctl devices 2>/dev/null | while read -r _ mac name; do
            [ -n "$mac" ] || continue
            if bluetoothctl info "$mac" 2>/dev/null | grep -q 'Connected: yes'; then
                state="conectado"
            else
                state="disponible"
            fi
            printf '%s\t%s (%s)\n' "$mac" "$name" "$state"
        done)
        selected=$(printf '%s\n' "$devices" | wofi_menu "Dispositivo Bluetooth")
        mac=$(printf '%s' "$selected" | cut -f1)
        [ -n "$mac" ] || exit 0
        if bluetoothctl info "$mac" 2>/dev/null | grep -q 'Connected: yes'; then
            bluetoothctl disconnect "$mac"
        else
            bluetoothctl pair "$mac" >/dev/null 2>&1 || true
            bluetoothctl trust "$mac" >/dev/null 2>&1 || true
            bluetoothctl connect "$mac"
        fi
        ;;
esac

pkill -RTMIN+9 waybar 2>/dev/null || true
