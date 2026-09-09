#!/bin/bash

# Obtener los nombres por defecto actuales
default_sink=$(pactl get-default-sink 2>/dev/null)
default_source=$(pactl get-default-source 2>/dev/null)

# Generar JSON de dispositivos de salida (Sinks)
sinks_json=$(pactl list sinks 2>/dev/null | awk '
    BEGIN { name=""; desc=""; }
    /^Sink #/ { 
        if (name != "") print_item();
        name=""; desc="";
    }
    /^\tName: / { name=$2; }
    /^\tDescription: / { 
        $1=""; desc=substr($0, 2); 
    }
    END { if (name != "") print_item(); }
    function print_item() {
        print name "|" desc;
    }
' | while IFS='|' read -r name desc; do
    [ -z "$name" ] && continue
    
    # Traducir a nombres amigables
    friendly_name="$desc"
    type="speaker"
    if [[ "$desc" =~ [Bb]luetooth|[Bb]lueZ|[Hh]eadset ]] || [[ "$name" =~ [Bb]luetooth ]]; then
        friendly_name="Auriculares Bluetooth"
        type="bluetooth"
    elif [[ "$desc" =~ [Hh]dmi|[Dd]isplayPort ]]; then
        friendly_name="Audio HDMI / Monitor"
    elif [[ "$desc" =~ [Uu]sb|[Uu]SB ]]; then
        friendly_name="Dispositivo USB"
    else
        friendly_name="Altavoces del Sistema"
    fi

    active=false
    [ "$name" = "$default_sink" ] && active=true

    jq -n --arg id "$name" --arg name "$friendly_name" --arg type "$type" --argjson active "$active" \
          '{id: $id, name: $name, type: $type, active: $active}'
done | jq -s '.')

# Generar JSON de dispositivos de entrada (Sources - omitiendo monitores internos)
sources_json=$(pactl list sources 2>/dev/null | awk '
    BEGIN { name=""; desc=""; monitor=0; }
    /^Source #/ { 
        if (name != "" && monitor == 0) print_item();
        name=""; desc=""; monitor=0;
    }
    /^\tName: / { name=$2; if ($2 ~ /\.monitor$/) monitor=1; }
    /^\tDescription: / { 
        $1=""; desc=substr($0, 2); 
    }
    END { if (name != "" && monitor == 0) print_item(); }
    function print_item() {
        print name "|" desc;
    }
' | while IFS='|' read -r name desc; do
    [ -z "$name" ] && continue
    
    friendly_name="Micrófono del Sistema"
    if [[ "$desc" =~ [Bb]luetooth|[Bb]lueZ ]] || [[ "$name" =~ [Bb]luetooth ]]; then
        friendly_name="Micrófono Bluetooth"
    elif [[ "$desc" =~ [Uu]sb|[Uu]SB ]]; then
        friendly_name="Micrófono USB"
    fi

    active=false
    [ "$name" = "$default_source" ] && active=true

    jq -n --arg id "$name" --arg name "$friendly_name" --argjson active "$active" \
          '{id: $id, name: $name, active: $active}'
done | jq -s '.')

# Imprimir ambos resultados combinados en un objeto JSON global que Eww pueda leer
jq -n --argjson sinks "${sinks_json:-[]}" --argjson sources "${sources_json:-[]}" \
      '{sinks: $sinks, sources: $sources}'