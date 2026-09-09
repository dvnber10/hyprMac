#!/bin/sh
wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
pkill -RTMIN+10 waybar 2>/dev/null || true
