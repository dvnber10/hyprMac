#!/usr/bin/env bash
# ~/.config/eww/scripts/get_audio_sources.sh

# Devuelve un array JSON con las fuentes de audio (micrófonos) excluyendo monitores internos
pactl -f json list sources 2>/dev/null | jq -c '[.[] | select(.monitor_of_sink == null) | {name: .name, description: .description}]'