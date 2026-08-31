#!/bin/bash
SSID="$1"
if nmcli -t -f NAME connection show 2>/dev/null | grep -Fxq "$SSID"; then
    nmcli connection up "$SSID"
else
    nmcli device wifi connect "$SSID"
fi