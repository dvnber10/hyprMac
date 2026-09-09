#!/bin/sh
set -u

eww_cmd="eww -c $HOME/.config/eww"
qr_path="/tmp/eww-wifi-qr.png"
ssid=$(nmcli -t -f ACTIVE,SSID dev wifi 2>/dev/null | sed -n 's/^yes://p' | head -n1)

if [ -z "$ssid" ]; then
    notify-send "Wi-Fi" "No hay una red Wi-Fi conectada"
    exit 0
fi

if ! command -v qrencode >/dev/null 2>&1; then
    notify-send "Wi-Fi" "qrencode no esta instalado"
    exit 0
fi

password=$(nmcli -s -g 802-11-wireless-security.psk connection show "$ssid" 2>/dev/null || true)
security=$(nmcli -t -f 802-11-wireless-security.key-mgmt connection show "$ssid" 2>/dev/null | cut -d: -f2- | head -n1 || true)
[ -n "$security" ] || security="WPA"
[ "$security" = "wpa-psk" ] && security="WPA"

qrencode -o "$qr_path" "WIFI:T:${security};S:${ssid};P:${password};;"
if [ "$($eww_cmd get popup_open 2>/dev/null || true)" = "control-center" ]; then
    $eww_cmd update cc_view=wifi-qr
else
    ~/.config/eww/scripts/close_popups.sh || true
    $eww_cmd update popup_open=control-center
    $eww_cmd update cc_view=wifi-qr
    $eww_cmd open click-catcher
    $eww_cmd open control-center
fi

$eww_cmd update cc_view=wifi-qr
