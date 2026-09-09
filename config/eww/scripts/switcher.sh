#!/bin/bash
# ~/.config/eww/scripts/switcher.sh
# Selector de ventanas estilo KDE Alt+Tab

STATE_FILE="/tmp/eww-switcher-state.json"
THUMB_DIR="/tmp/eww-switcher-thumbs"
ACTION="${1:-toggle}"
WORKSPACE=$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.id // 0')

mkdir -p "$THUMB_DIR"

# Obtener ventanas del workspace actual (no minimizadas, no especiales, no el switcher mismo)
get_windows() {
    hyprctl clients -j 2>/dev/null | jq -r --argjson ws "$WORKSPACE" '
        [.[] 
        | select(.workspace.id == $ws)
        | select(.mapped == true)
        | select(.hidden == false)
        | select(([.tags[]? // empty] | map(select(. == "minimized")) | length) == 0)
        | select(.class != "eww")
        | {address, title, class, at: (.at // [0,0]), size: (.size // [0,0]), focusHistoryID}
        ] | sort_by(.focusHistoryID) | reverse'
}

# Capturar thumbnail de una ventana
capture_thumb() {
    local ADDR="$1"
    local X Y W H
    X=$(echo "$WIN_DATA" | jq -r --arg a "$ADDR" '.[] | select(.address == $a) | .at[0]')
    Y=$(echo "$WIN_DATA" | jq -r --arg a "$ADDR" '.[] | select(.address == $a) | .at[1]')
    W=$(echo "$WIN_DATA" | jq -r --arg a "$ADDR" '.[] | select(.address == $a) | .size[0]')
    H=$(echo "$WIN_DATA" | jq -r --arg a "$ADDR" '.[] | select(.address == $a) | .size[1]')

    if [ "$W" -gt 0 ] 2>/dev/null && [ "$H" -gt 0 ] 2>/dev/null; then
        # Calcular tamaño proporcional (max 200px ancho)
        local SCALE=200
        local TH=$((H * SCALE / W))
        [ "$TH" -lt 1 ] && TH=1
        timeout 3 grim -g "${X},${Y} ${W}x${H}" "${THUMB_DIR}/${ADDR}.png" 2>/dev/null
        timeout 3 ffmpeg -y -i "${THUMB_DIR}/${ADDR}.png" -vf "scale=${SCALE}:${TH}:flags=lanczos" "${THUMB_DIR}/${ADDR}_thumb.png" 2>/dev/null
        rm -f "${THUMB_DIR}/${ADDR}.png" 2>/dev/null
    fi
}

case "$ACTION" in
    open|next)
        WIN_DATA=$(get_windows)
        WIN_COUNT=$(echo "$WIN_DATA" | jq 'length')

        if [ "$WIN_COUNT" -lt 1 ]; then
            echo "[]" > "$STATE_FILE"
            eww close switcher 2>/dev/null
            exit 0
        fi

        # Cargar estado actual o crear nuevo
        if [ -f "$STATE_FILE" ] && eww active-windows 2>/dev/null | grep -q "switcher"; then
            CURRENT_IDX=$(jq -r '.index // 0' "$STATE_FILE")
            CURRENT_IDX=$(( (CURRENT_IDX + 1) % WIN_COUNT ))
        else
            CURRENT_IDX=0
        fi

        # Guardar estado
        echo "$WIN_DATA" | jq -n --argjson idx "$CURRENT_IDX" '{index: $idx, windows: input}' > "$STATE_FILE"

        # Capturar thumbnails de las primeras ventanas visibles
        for i in 0 1 2 3 4 5 6 7; do
            ADDR=$(echo "$WIN_DATA" | jq -r ".[$i].address // empty")
            [ -z "$ADDR" ] && continue
            [ ! -f "${THUMB_DIR}/${ADDR}_thumb.png" ] && capture_thumb "$ADDR" &
        done
        wait

        # Construir datos para EWW
        EWW_DATA=$(echo "$WIN_DATA" | jq -c '[.[] | {
            address: .address,
            title: (.title | tostring | if length > 30 then .[:27] + "..." else . end),
            class: .class,
            thumb: "/tmp/eww-switcher-thumbs/" + .address + "_thumb.png",
            selected: (if .address == (input | .address) then true else false end)
        }]' --argjson sel "$(echo "$WIN_DATA" | jq -c ".[$CURRENT_IDX]")")

        eww open switcher --size 900 240 --override "window-layer=overlay" --override "window-type=dialog" 2>/dev/null
        eww update switcher_data="$EWW_DATA" 2>/dev/null
        ;;

    prev)
        WIN_DATA=$(get_windows)
        WIN_COUNT=$(echo "$WIN_DATA" | jq 'length')

        if [ "$WIN_COUNT" -lt 1 ]; then
            eww close switcher 2>/dev/null
            exit 0
        fi

        CURRENT_IDX=$(jq -r '.index // 0' "$STATE_FILE" 2>/dev/null || echo "0")
        CURRENT_IDX=$(( (CURRENT_IDX - 1 + WIN_COUNT) % WIN_COUNT ))

        echo "$WIN_DATA" | jq -n --argjson idx "$CURRENT_IDX" '{index: $idx, windows: input}' > "$STATE_FILE"

        EWW_DATA=$(echo "$WIN_DATA" | jq -c '[.[] | {
            address: .address,
            title: (.title | tostring | if length > 30 then .[:27] + "..." else . end),
            class: .class,
            thumb: "/tmp/eww-switcher-thumbs/" + .address + "_thumb.png",
            selected: (if .address == (input | .address) then true else false end)
        }]' --argjson sel "$(echo "$WIN_DATA" | jq -c ".[$CURRENT_IDX]")")

        eww update switcher_data="$EWW_DATA" 2>/dev/null
        ;;

    close)
        if [ -f "$STATE_FILE" ]; then
            WIN_COUNT=$(jq '.windows | length' "$STATE_FILE" 2>/dev/null)
            if [ "$WIN_COUNT" -gt 0 ]; then
                CURRENT_IDX=$(jq -r '.index // 0' "$STATE_FILE")
                SELECTED=$(jq -r ".windows[$CURRENT_IDX].address" "$STATE_FILE")

                if [ -n "$SELECTED" ] && [ "$SELECTED" != "null" ]; then
                    # Enfocar ventana seleccionada
                    hyprctl eval "hl.dispatch(hl.dsp.focus({window = 'address:${SELECTED}'}))" 2>/dev/null
                fi
            fi
            rm -f "$STATE_FILE"
        fi
        rm -f "${THUMB_DIR}"/*_thumb.png 2>/dev/null
        eww close switcher 2>/dev/null
        ;;

    cancel)
        rm -f "$STATE_FILE"
        rm -f "${THUMB_DIR}"/*_thumb.png 2>/dev/null
        eww close switcher 2>/dev/null
        ;;
esac
