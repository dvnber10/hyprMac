#!/usr/bin/env bash
# ~/.config/eww/scripts/get_audio_outputs.sh

# Devuelve un array JSON con los sinks de PulseAudio/PipeWire
pactl -f json list sinks 2>/dev/null | jq -c '[.[] | {name: .name, description: .description}]'