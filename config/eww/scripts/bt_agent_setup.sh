#!/bin/bash
# Mantiene bluetoothctl corriendo en segundo plano con un agente
# "NoInputNoOutput": acepta el emparejamiento automáticamente sin
# pedir PIN. Agrega esto a tu autostart de hyprland.lua:
#   hl.exec_cmd("~/.config/hypr/scripts/bt_agent_setup.sh")
(
  echo -e "agent NoInputNoOutput\ndefault-agent\n"
  sleep infinity
) | bluetoothctl &>/dev/null &
disown