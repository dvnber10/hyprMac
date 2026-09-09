#!/bin/bash
# Script para alternar el estado de la Dynamic Island

current_state=$(eww get island_state 2>/dev/null || echo "collapsed")

case "$current_state" in
    "collapsed")
        # Si hay música, expandir a música
        media=$(eww get media_json 2>/dev/null)
        if [ -n "$media" ] && echo "$media" | jq -e '.playing == true and .title != ""' >/dev/null 2>&1; then
            eww update island_state=media
        # Si hay notificación, expandir a notificación
        elif [ -n "$(eww get last_notification 2>/dev/null | jq -r '.summary // empty')" ]; then
            eww update island_state=notification
        fi
        ;;
    "media"|"notification")
        eww update island_state=collapsed
        ;;
    *)
        eww update island_state=collapsed
        ;;
esac