#!/bin/bash
MAC="$1"
bluetoothctl pair "$MAC" &>/dev/null
bluetoothctl trust "$MAC" &>/dev/null
bluetoothctl connect "$MAC"