#!/bin/bash
if command -v powerprofilesctl &> /dev/null; then
    powerprofilesctl set "$1"
fi