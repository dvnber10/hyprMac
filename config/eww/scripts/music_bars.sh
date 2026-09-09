#!/usr/bin/env bash
cava -p "$HOME/.config/eww/scripts/cava_eww.conf" | while read -r line; do
  line="${line%;}"
  echo "[${line//;/,}]"
done