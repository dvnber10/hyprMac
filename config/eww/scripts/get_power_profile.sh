#!/bin/bash
if command -v powerprofilesctl &> /dev/null; then
    powerprofilesctl get
else
    echo "balanced"
fi