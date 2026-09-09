#!/bin/bash
# Lanza wdisplays con las variables de Wayland correctas
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
wdisplays &
