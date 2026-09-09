#!/bin/bash
# Script para actualizar el estado de la Dynamic Island basado en la música

media=$(eww get media_json 2>/dev/null)

if [ -n "$media" ] && echo "$media" | jq -e '.playing == true and .title != ""' >/dev/null 2>&1; then
    # Hay música sonando
    current_state=$(eww get island_state 2>/dev/null || echo "collapsed")
    if [ "$current_state" = "collapsed" ] || [ "$current_state" = "notification" ]; then
        eww update island_state=media
    fi
else
    # No hay música
    current_state=$(eww get island_state 2>/dev/null || echo "collapsed")
    if [ "$current_state" = "media" ]; then
        eww update island_state=collapsed
    fi
fi