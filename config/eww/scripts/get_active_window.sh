#!/bin/bash
hyprctl activewindow -j 2>/dev/null | jq -r '.title // ""'