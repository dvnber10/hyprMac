#!/bin/sh
if wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | grep -q MUTED; then
    echo true
else
    echo false
fi
