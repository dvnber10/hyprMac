#!/bin/bash
wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null | awk '{print int($2 * 100)}' || echo "0"