#!/bin/bash
# ~/.config/hypr/scripts/auto_minimize_daemon.sh
# Cuando se abre una ventana NUEVA, minimiza la que estaba visible en ese workspace.
# Solo actúa si la ventana nueva tiene clase DIFERENTE (misma app = misma ventana).

PREV_SNAPSHOT=""
PREV_WS_ID=""
LAUNCH_TIME=$(date +%s)
# Lock file para evitar conflictos con restore
LOCK_FILE="/tmp/eww-minimized.lock"

while true; do
    NOW=$(date +%s)
    # Ignorar los primeros 5 segundos
    # [ $((NOW - LAUNCH_TIME)) -lt 5 ] && sleep 1 && continue

    # Si hay un restore en progreso, saltar
    [ -f "$LOCK_FILE" ] && sleep 0.3 && continue

    WS_ID=$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.id // 0')
    WS_NAME=$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.name // ""')

    if [ "$WS_ID" != "$PREV_WS_ID" ]; then
        PREV_WS_ID="$WS_ID"
        PREV_SNAPSHOT="$CURRENT_SNAPSHOT"
        sleep 1
        continue
    fi

    # Ignorar workspaces especiales
    echo "$WS_NAME" | grep -q "^special:" && sleep 1 && continue

    # Snapshot actual: address,class de ventanas visibles en este workspace
    CURRENT_SNAPSHOT=$(hyprctl clients -j 2>/dev/null | jq -r --argjson ws "$WS_ID" '
        [.[] | select(.workspace.id == $ws)
         | select(.tags | index("minimized") | not)
         | select(.mapped == true)]
        | sort_by(.address) | .[] | "\(.address) \(.class)"' 2>/dev/null)

    if [ -n "$PREV_SNAPSHOT" ] && [ -n "$CURRENT_SNAPSHOT" ]; then
        # Encontrar addresses que aparecieron nuevas
        PREV_ADDRS=$(echo "$PREV_SNAPSHOT" | awk '{print $1}' | sort)
        CURR_ADDRS=$(echo "$CURRENT_SNAPSHOT" | awk '{print $1}' | sort)

        NEW_ADDRS=$(comm -13 <(echo "$PREV_ADDRS") <(echo "$CURR_ADDRS"))

        for NEW_ADDR in $NEW_ADDRS; do
            [ -z "$NEW_ADDR" ] && continue
            # Skip si hay lock (restore en curso)
            [ -f "$LOCK_FILE" ] && break

            # Obtener clase de la ventana nueva
            NEW_CLASS=$(echo "$CURRENT_SNAPSHOT" | awk -v a="$NEW_ADDR" '$1==a {print $2}')

            # Encontrar la ventana que ESTABA antes (misma clase = misma app, no minimizar)
            OLD_VISIBLE=""
            while IFS= read -r line; do
                O_ADDR=$(echo "$line" | awk '{print $1}')
                O_CLASS=$(echo "$line" | awk '{print $2}')
                if [ "$O_CLASS" = "$NEW_CLASS" ]; then
                    continue  # misma app, no minimizar
                fi
                # Esta ventana estaba visible antes y sigue aquí → minimizar
                STILL_EXISTS=$(hyprctl clients -j 2>/dev/null | jq -r --arg a "$O_ADDR" '[.[] | select(.address == $a and .mapped == true)] | length')
                if [ "$STILL_EXISTS" = "1" ]; then
                    OLD_VISIBLE="$O_ADDR"
                    break
                fi
            done <<< "$PREV_SNAPSHOT"

            if [ -n "$OLD_VISIBLE" ]; then
                # Minimizar en background, sin锁
                bash ~/.config/hypr/scripts/macos_minimize_daemon.sh "$OLD_VISIBLE" "" &
            fi
        done
    fi

    PREV_SNAPSHOT="$CURRENT_SNAPSHOT"
    sleep 0.5
done
