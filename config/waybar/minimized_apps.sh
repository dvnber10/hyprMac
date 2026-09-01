#!/bin/bash

clients=$(hyprctl clients -j | jq -c '[.[] | select(.workspace.name == "special:minimized")]')
count=$(jq 'length' <<< "$clients")

if [[ "${1:-}" == "--restore" && "$count" -gt 0 ]]; then
    choices=$(jq -r '.[] | [.address, (.title // .class // "Ventana")] | @tsv' <<< "$clients")
    selected=$(printf '%s\n' "$choices" | cut -f2- | wofi --dmenu --prompt "Ventanas minimizadas" --cache-file /dev/null)
    address=$(awk -F '\t' -v title="$selected" '$2 == title { print $1; exit }' <<< "$choices")

    if [[ -n "$address" ]]; then
        target=$(hyprctl activeworkspace -j | jq -r '.id')
        hyprctl dispatch movetoworkspacesilent "$target,address:$address"
        hyprctl dispatch focuswindow "address:$address"
        pkill -RTMIN+8 waybar 2>/dev/null
    fi
    exit 0
fi

if [[ "$count" -eq 0 ]]; then
    jq -cn '{text: "", tooltip: "No hay ventanas minimizadas", class: "empty"}'
    exit 0
fi

titles=$(jq -r 'map(.title // .class // "Ventana") | join(", ")' <<< "$clients")
jq -cn --arg text "  $titles " --arg tooltip "$titles" \
    '{text: $text, tooltip: $tooltip, class: "has-items"}'