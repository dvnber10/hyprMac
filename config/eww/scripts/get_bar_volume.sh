#!/bin/bash
vol_raw=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
vol=$(echo "$vol_raw" | awk '{print int($2 * 100)}')
muted=false
echo "$vol_raw" | grep -q MUTED && muted=true

if [ "$muted" = "true" ]; then
    icon=""
elif [ "$vol" -ge 50 ]; then
    icon=""
else
    icon=""
fi

echo "{\"percent\": $vol, \"icon\": \"$icon\", \"muted\": $muted}"