#!/bin/bash

if command -v rofi >/dev/null 2>&1; then
    exec rofi -show drun -theme ~/.config/rofi/launchpad.rasi
fi

exec rofi -show drun -theme ~/.config/rofi/launchpad.rasi  
