#!/bin/bash
VOLUME=$(echo "$1" | cut -d'.' -f1)
wpctl set-volume @DEFAULT_AUDIO_SINK@ "${VOLUME}%"