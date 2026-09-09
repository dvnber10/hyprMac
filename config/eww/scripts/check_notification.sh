#!/bin/bash
# Script para verificar notificaciones y actualizar la Dynamic Island

notif=$(eww get last_notification 2>/dev/null)

if [ -n "$notif" ]; then
    summary=$(echo "$notif" | jq -r '.summary // ""')
    if [ -n "$summary" ] && [ "$summary" != "null" ]; then
        # Hay notificación
        current_state=$(eww get island_state 2>/dev/null || echo "collapsed")
        if [ "$current_state" = "collapsed" ] || [ "$current_state" = "media" ]; then
            eww update island_state=notification
        fi
    else
        # No hay notificación
        current_state=$(eww get island_state 2>/dev/null || echo "collapsed")
        if [ "$current_state" = "notification" ]; then
            # Verificar si hay música sonando
            media=$(eww get media_json 2>/dev/null)
            if [ -n "$media" ] && echo "$media" | jq -e '.playing == true and .title != ""' >/dev/null 2>&1; then
                eww update island_state=media
            else
                eww update island_state=collapsed
            fi
        fi
    fi
fi