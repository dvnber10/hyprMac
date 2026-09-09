#!/bin/bash
# Devuelve JSON y mantiene en cache la caratula del reproductor activo.
art_path="/home/duvan/.config/eww/wallpapers/images/wall1.png"
art_cache="/tmp/eww-media-art.png"
art_source=$(playerctl metadata mpris:artUrl 2>/dev/null || true)
resized_art="/tmp/eww-media-art-resized.png"

if [[ "$art_source" == file://* ]]; then
    local_art=${art_source#file://}
    [[ -f "$local_art" ]] && art_path="$local_art"
elif [[ "$art_source" == http://* || "$art_source" == https://* ]] && command -v curl >/dev/null 2>&1; then
    if [[ ! -s "$art_cache" || "$(cat /tmp/eww-media-art-url 2>/dev/null)" != "$art_source" ]]; then
        if curl -L --fail --silent --show-error --max-time 5 "$art_source" -o "$art_cache"; then
            printf '%s' "$art_source" > /tmp/eww-media-art-url
        fi
    fi
    [[ -s "$art_cache" ]] && art_path="$art_cache"
fi

if ! command -v playerctl &>/dev/null || [ -z "$(playerctl -l 2>/dev/null)" ]; then
    printf '{"title":"","artist":"","playing":false,"art_path":"%s"}\n' "$art_path"
    exit 0
fi

if [[ "$art_path" != "$resized_art" ]] && [[ -f "$art_path" ]]; then
    ffmpeg -y -i "$art_path" -vf "scale=100:100:force_original_aspect_ratio=decrease,pad=112:112:(ow-iw)/2:(oh-ih)/2:color=0x00000000" "$resized_art" 2>/dev/null
    [[ -s "$resized_art" ]] && art_path="$resized_art"
fi

title=$(playerctl metadata title 2>/dev/null | sed 's/"/\\"/g')
artist=$(playerctl metadata artist 2>/dev/null | sed 's/"/\\"/g')
status=$(playerctl status 2>/dev/null)
playing=false
[ "$status" = "Playing" ] && playing=true

jq -cn --arg title "$title" --arg artist "$artist" --arg art_path "$art_path" \
    --argjson playing "$playing" \
    '{title:$title, artist:$artist, playing:$playing, art_path:$art_path}'