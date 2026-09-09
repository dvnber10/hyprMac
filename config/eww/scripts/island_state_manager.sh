#!/usr/bin/env bash
# notification_listener.sh
#
# Reemplaza a get_last_notification.sh. swaync-client NO tiene ningún flag
# que devuelva el contenido completo de una notificación en JSON (solo
# --count, --subscribe y --action), así que en vez de pedírselo a swaync,
# escuchamos directamente las llamadas Notify en el bus de sesión.
#
# Pensado para usarse con `deflisten` en el yuck: imprime UNA línea JSON
# por cada notificación nueva, y de paso abre/actualiza la isla.
#
# Requiere: busctl (paquete systemd), jq

set -u

FALLBACK='{"app":"","summary":"","body":"","urgency":"low","timestamp":0,"app_icon":"","actions":"0","action1_label":"","action1_cmd":"","action2_label":"","action2_cmd":""}'

if ! command -v busctl &>/dev/null; then
    echo "$FALLBACK"
    echo "notification_listener.sh: falta 'busctl' (paquete systemd)" >&2
    exit 1
fi

echo "$FALLBACK"   # valor inicial mientras no llega nada

# Envuelto en un loop con espera: si busctl muere o el pipe se corta,
# reintenta cada 3s en vez de salir (evita que eww lo relance en caliente
# a máxima velocidad si algo sale mal).
while true; do
  busctl --user monitor --json=short 2>/dev/null | while IFS= read -r line; do
    member=$(jq -r '.member // empty' 2>/dev/null <<< "$line")
    [[ "$member" != "Notify" ]] && continue

    iface=$(jq -r '.interface // empty' 2>/dev/null <<< "$line")
    [[ "$iface" != "org.freedesktop.Notifications" ]] && continue

    data=$(jq -c '.payload.data // empty' 2>/dev/null <<< "$line")
    [[ -z "$data" || "$data" == "null" ]] && continue

    app=$(jq -r '.[0] // "Desconocido"' <<< "$data")
    app_icon=$(jq -r '.[2] // ""' <<< "$data")
    summary=$(jq -r '.[3] // ""' <<< "$data")
    body=$(jq -r '.[4] // ""' <<< "$data")
    actions_raw=$(jq -c '.[5] // []' <<< "$data")

    [[ "$app_icon" == "null" ]] && app_icon=""
    # Algunas apps mandan un nombre de ícono del tema (ej. "dialog-information")
    # en vez de una ruta de archivo; el widget image de eww solo sabe leer
    # archivos, así que si no es una ruta real y existente, la descartamos.
    [[ -n "$app_icon" && ! -f "$app_icon" ]] && app_icon=""

    # las acciones vienen intercaladas [id1, label1, id2, label2, ...]
    action1_label=$(jq -r '.[1] // ""' <<< "$actions_raw")
    action2_label=$(jq -r '.[3] // ""' <<< "$actions_raw")
    actions_count=$(jq 'length / 2 | floor' <<< "$actions_raw")

    action1_cmd=""
    action2_cmd=""
    [[ "$actions_count" -ge 1 ]] && action1_cmd="swaync-client -a 0 && eww update island_state=collapsed"
    [[ "$actions_count" -ge 2 ]] && action2_cmd="swaync-client -a 1 && eww update island_state=collapsed"

    json=$(jq -cn \
        --arg app "$app" \
        --arg summary "$summary" \
        --arg body "$body" \
        --arg app_icon "$app_icon" \
        --arg actions "$actions_count" \
        --arg action1_label "$action1_label" \
        --arg action1_cmd "$action1_cmd" \
        --arg action2_label "$action2_label" \
        --arg action2_cmd "$action2_cmd" \
        --argjson timestamp "$(date +%s)" \
        '{
            app: $app,
            summary: $summary,
            body: $body,
            urgency: "normal",
            timestamp: $timestamp,
            app_icon: $app_icon,
            actions: $actions,
            action1_label: $action1_label,
            action1_cmd: $action1_cmd,
            action2_label: $action2_label,
            action2_cmd: $action2_cmd
        }')

    echo "$json"

    # Efecto secundario: abre la isla en modo notificación.
    eww update has_notification=true island_state=notification 2>/dev/null
    eww open dynamic-island 2>/dev/null

    (
        sleep 5
        if [[ "$(eww get island_state 2>/dev/null)" == "notification" ]]; then
            if [[ "$(playerctl status 2>/dev/null)" == "Playing" ]]; then
                eww update island_state=media
            else
                eww update island_state=collapsed has_notification=false
                eww close dynamic-island 2>/dev/null
            fi
        fi
    ) &
  done
  sleep 3
done