#!/bin/bash
bat_path=$(find /sys/class/power_supply -maxdepth 1 -name "BAT*" | head -n1)
if [ -z "$bat_path" ]; then
    echo -1
else
    cat "$bat_path/capacity" 2>/dev/null || echo 0
fi
