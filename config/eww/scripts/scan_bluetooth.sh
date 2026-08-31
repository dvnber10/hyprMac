#!/bin/bash
bluetoothctl scan on &>/dev/null &
SCAN_PID=$!
sleep 3
kill "$SCAN_PID" 2>/dev/null
bluetoothctl scan off &>/dev/null

bluetoothctl devices 2>/dev/null | while read -r _ mac name; do
    [ -z "$mac" ] && continue
    connected=false
    bluetoothctl info "$mac" 2>/dev/null | grep -q "Connected: yes" && connected=true
    jq -n --arg mac "$mac" --arg name "$name" --argjson connected "$connected" \
          '{mac:$mac, name:$name, connected:$connected}'
done | jq -s '.'