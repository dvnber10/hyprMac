#!/bin/bash
# ============================================================
# wp_nav.sh — Navegación del carrusel de wallpapers para eww
# Uso: wp_nav.sh <prev|next|apply|close|init>
# Maneja el estado y empuja todo a eww via `eww update`
# ============================================================

WALLPAPER_DIR="$HOME/.config/eww/wallpapers"
STATE_DIR="$HOME/.cache/eww_wallpaper"
STATE_FILE="$STATE_DIR/index"
WALLS_FILE="$STATE_DIR/walls"

mkdir -p "$STATE_DIR"

# ── Cargar/generar lista de wallpapers ──
if [ -f "$WALLS_FILE" ]; then
    mapfile -t WALLS < "$WALLS_FILE"
    WALLS=(${WALLS[@]})
else
    while IFS= read -r -d '' f; do
        WALLS+=("$f")
    done < <(find "$WALLPAPER_DIR" -maxdepth 2 -type f \( \
        -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \
        -o -iname "*.webp" -o -iname "*.bmp" \
    \) -print0 2>/dev/null | sort -z)
    printf '%s\n' "${WALLS[@]}" > "$WALLS_FILE"
fi

TOTAL=${#WALLS[@]}

if [ "$TOTAL" -eq 0 ]; then
    eww update wp_cur_path="" wp_cur_name="Sin wallpapers" wp_prev_path="" wp_next_path="" wp_index=0 wp_total=0 wp_dots=""
    exit 0
fi

# ── Push completo a eww ──
push_all() {
    local idx="$1"
    local total="$2"
    local prev_idx=$(( (idx - 1 + total) % total ))
    local next_idx=$(( (idx + 1) % total ))
    local cur="${WALLS[$idx]}"
    local prev="${WALLS[$prev_idx]}"
    local next="${WALLS[$next_idx]}"
    local name=$(basename "$cur")
    local dots=""
    for ((i = 0; i < total; i++)); do
        [ "$i" -eq "$idx" ] && dots="${dots}● " || dots="${dots}○ "
    done
    eww update \
        wp_cur_path="$cur" \
        wp_cur_name="$name" \
        wp_prev_path="$prev" \
        wp_next_path="$next" \
        wp_index="$idx" \
        wp_total="$total" \
        wp_dots="${dots% }"
}

# ── Índice actual ──
IDX=$(cat "$STATE_FILE" 2>/dev/null || echo 0)
[ "$IDX" -ge "$TOTAL" ] && IDX=0
[ "$IDX" -lt 0 ] && IDX=$((TOTAL - 1))

case "${1:-init}" in
    prev)
        IDX=$(( (IDX - 1 + TOTAL) % TOTAL ))
        echo "$IDX" > "$STATE_FILE"
        push_all "$IDX" "$TOTAL"
        ;;
    next)
        IDX=$(( (IDX + 1) % TOTAL ))
        echo "$IDX" > "$STATE_FILE"
        push_all "$IDX" "$TOTAL"
        ;;
    apply)
        CUR="${WALLS[$IDX]}"
        if [ -f "$CUR" ]; then
            echo "$CUR" > "$HOME/.cache/current_wallpaper"
            /usr/bin/awww img "$CUR" 2>/dev/null
            notify-send "Wallpaper" "Aplicado: $(basename "$CUR")" -i "$CUR" -t 2000
        fi
        ;;
    close)
        eww close wallpaper-carousel
        ;;
    init)
        push_all "$IDX" "$TOTAL"
        ;;
esac
