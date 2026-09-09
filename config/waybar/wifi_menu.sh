#!/bin/sh

wofi_menu() {
    wofi --dmenu --prompt "$1" --cache-file /dev/null --allow-markup --insensitive
}

wifi_state=$(nmcli radio wifi 2>/dev/null)
if [ "$wifi_state" = "enabled" ]; then
    toggle="󰤭  Desactivar Wi-Fi"
else
    toggle="󰤨  Activar Wi-Fi"
fi

active=$(nmcli -t -f ACTIVE,SSID dev wifi 2>/dev/null | sed -n 's/^yes://p' | head -n1)
[ -n "$active" ] && current="󰤨  Conectado: $active" || current="󰤭  Sin conexión"

choice=$(printf '%s\n%s\n󰑐  Buscar redes\n󰌾  Mostrar QR de red actual\n󰒍  Abrir configuración de red\n' \
    "$toggle" "$current" | wofi_menu "Wi-Fi")

case "$choice" in
    *"Desactivar Wi-Fi")
        nmcli radio wifi off
        ;;
    *"Activar Wi-Fi")
        nmcli radio wifi on
        ;;
    *"Mostrar QR"*)
        if ! command -v qrencode >/dev/null 2>&1; then
            notify-send "Wi-Fi" "Instala qrencode para mostrar códigos QR"
            exit 0
        fi
        if [ -z "$active" ]; then
            notify-send "Wi-Fi" "No hay una red Wi-Fi conectada"
            exit 0
        fi
        password=$(nmcli -s -g 802-11-wireless-security.psk connection show "$active" 2>/dev/null)
        security=$(nmcli -t -f 802-11-wireless-security.key-mgmt connection show "$active" 2>/dev/null | head -n1)
        [ -z "$security" ] && security="WPA"
        ~/.config/eww/scripts/show_wifi_qr.sh
        ;;
    *"Abrir configuración"*)
        nm-connection-editor >/dev/null 2>&1 &
        ;;
    *"Buscar redes"*)
        networks=$(nmcli -t -f SSID,SIGNAL,SECURITY,IN-USE dev wifi list 2>/dev/null | awk -F: 'NF >= 2 && $1 != "" { printf "%s\t%s%%\t%s\n", $1, $2, ($3 == "--" ? "abierta" : "protegida") }' | sort -t '%%' -k2,2nr | awk '!seen[$1]++')
        selected=$(printf '%s\n' "$networks" | wofi_menu "Red Wi-Fi")
        ssid=$(printf '%s' "$selected" | cut -f1)
        [ -z "$ssid" ] && exit 0
        if nmcli -t -f NAME connection show | grep -Fxq "$ssid"; then
            nmcli connection up "$ssid"
        else
            password=$(wofi --dmenu --password --prompt "Contraseña: $ssid" --cache-file /dev/null)
            [ -n "$password" ] && nmcli device wifi connect "$ssid" password "$password"
        fi
        ;;
esac

pkill -RTMIN+8 waybar 2>/dev/null || true
