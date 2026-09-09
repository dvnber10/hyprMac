#!/bin/bash

# Realizar un escaneo rápido en segundo plano
bluetoothctl scan on &>/dev/null &
SCAN_PID=$!
sleep 1
kill "$SCAN_PID" 2>/dev/null
bluetoothctl scan off &>/dev/null

bluetoothctl devices 2>/dev/null | while read -r _ mac name; do
    [ -z "$mac" ] && continue
    
    connected=false
    battery=""
    rssi=""
    
    # Obtener información detallada del dispositivo
    info=$(bluetoothctl info "$mac" 2>/dev/null)
    
    # Verificar si está conectado
    echo "$info" | grep -q "Connected: yes" && connected=true
    
    # Extraer porcentaje de batería si está disponible (Battery Percentage: 0x64 (100))
    bat_line=$(echo "$info" | grep -i "Battery Percentage")
    if [ -n "$bat_line" ]; then
        # Extraer el valor numérico (soporta formato hexadecimal o decimal común)
        hex_val=$(echo "$bat_line" | awk -F '[()]' '{print $2}')
        if [[ "$hex_val" =~ ^0x ]]; then
            battery=$((hex_val))
        else
            battery=$(echo "$bat_line" | awk '{print $NF}' | tr -d '()%')
        fi
    fi

    # Extraer RSSI (señal) si el dispositivo lo reporta en la info
    rssi_line=$(echo "$info" | grep -i "RSSI")
    if [ -n "$rssi_line" ]; then
        rssi=$(echo "$rssi_line" | awk '{print $2}')
    fi

    # Construir el JSON usando jq de manera segura
    jq -n --arg mac "$mac" \
          --arg name "$name" \
          --argjson connected "$connected" \
          --arg battery "$battery" \
          --arg rssi "$rssi" \
          '{mac: $mac, name: $name, connected: $connected, battery: $battery, rssi: $rssi}'
done | jq -s '.'