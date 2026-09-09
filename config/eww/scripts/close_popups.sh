#!/bin/bash
eww -c $HOME/.config/eww update popup_open=none
eww -c $HOME/.config/eww close \
	control-center apple-menu click-catcher \
	wifi-menu bluetooth-menu audio-menu battery-menu wifi-qr-menu calendar \
	menu-archivo menu-edicion menu-ver menu-ventana menu-ayuda \
	menu-global menu-global-archivo menu-global-edicion menu-global-seleccion \
	menu-global-ver menu-global-historial menu-global-marcadores \
	menu-global-herramientas menu-global-terminal menu-global-ir \
	menu-global-ejecutar menu-global-ventana menu-global-ayuda 2>/dev/null || true
