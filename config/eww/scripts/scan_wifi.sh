#!/bin/bash
nmcli device wifi rescan 2>/dev/null
nmcli -t -f SSID,SIGNAL,SECURITY,IN-USE dev wifi list 2>/dev/null | while IFS=: read -r ssid signal security inuse; do
    [ -z "$ssid" ] && continue
    secured=false
    [ -n "$security" ] && [ "$security" != "--" ] && secured=true
    connected=false
    [ "$inuse" = "*" ] && connected=true
    # ¿Ya la conocemos? (conexión guardada con ese nombre) -> no pedimos password
    known=false
    nmcli -t -f NAME connection show 2>/dev/null | grep -Fxq "$ssid" && known=true
    jq -n --arg ssid "$ssid" --argjson signal "${signal:-0}" \
          --argjson secured "$secured" --argjson connected "$connected" --argjson known "$known" \
          '{ssid:$ssid, signal:$signal, secured:$secured, connected:$connected, known:$known}'
done | jq -s 'unique_by(.ssid) | sort_by(-.signal)'