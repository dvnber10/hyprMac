#!/bin/bash

pkill -x wofi 2>/dev/null || true

menu_output=$(mktemp)
menu_input=$(cat)
cleanup() {
    rm -f "$menu_output"
}
trap cleanup EXIT

printf '%s\n' "$menu_input" | wofi --dmenu --hide-search --no-custom-entry --allow-markup "$@" >"$menu_output" &
wofi_pid=$!
wait "$wofi_pid" 2>/dev/null || true
cat "$menu_output"
