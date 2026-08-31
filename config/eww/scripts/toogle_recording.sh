
#!/bin/bash
# Requiere: sudo pacman -S wf-recorder
# Cambia esto por el grabador que realmente tengas instalado si usas otro.
if pgrep -x wf-recorder > /dev/null; then
    pkill -INT -x wf-recorder
    notify-send "Grabación" "Detenida"
else
    mkdir -p ~/Videos
    wf-recorder -f ~/Videos/recording-$(date +%Y%m%d-%H%M%S).mp4 &
    notify-send "Grabación" "Iniciada"
fi