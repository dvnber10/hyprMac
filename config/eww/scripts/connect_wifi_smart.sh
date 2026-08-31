#!/bin/bash
SSID="$1"
PASSWORD="$2"
nmcli device wifi connect "$SSID" password "$PASSWORD"