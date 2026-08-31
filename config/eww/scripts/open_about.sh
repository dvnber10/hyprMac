#!/bin/bash
# "Acerca de este sistema" - Versión completa con YAD

# Función para obtener información del sistema
get_system_info() {
    # Información básica
    hostname=$(hostname)
    kernel=$(uname -r)
    os=$(lsb_release -ds 2>/dev/null || cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)
    uptime=$(uptime -p | sed 's/up //')
    
    # CPU
    cpu_model=$(grep -m1 "model name" /proc/cpuinfo | cut -d: -f2 | sed 's/^ //')
    cpu_cores=$(nproc)
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1)
    
    # Temperatura CPU
    if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
        temp=$(($(cat /sys/class/thermal/thermal_zone0/temp) / 1000))
        temp_info="${temp}°C"
    else
        temp_info="No disponible"
    fi
    
    # Memoria RAM
    mem_total=$(free -h | awk '/^Mem:/ {print $2}')
    mem_used=$(free -h | awk '/^Mem:/ {print $3}')
    mem_percent=$(free | awk '/^Mem:/ {printf "%.1f", ($3/$2)*100}')
    
    # Swap
    swap_total=$(free -h | awk '/^Swap:/ {print $2}')
    swap_used=$(free -h | awk '/^Swap:/ {print $3}')
    
    # Disco
    disk_total=$(df -h / | awk 'NR==2 {print $2}')
    disk_used=$(df -h / | awk 'NR==2 {print $3}')
    disk_percent=$(df -h / | awk 'NR==2 {print $5}')
    
    # Red
    interface=$(ip route | grep default | awk '{print $5}' | head -1)
    ip_address=$(ip -4 addr show $interface 2>/dev/null | grep inet | awk '{print $2}' | cut -d/ -f1 | head -1)
    wifi_ssid=$(nmcli -t -f NAME connection show --active 2>/dev/null | head -1)
    
    # GPU
    if command -v lspci &> /dev/null; then
        gpu=$(lspci | grep -i "vga\|3d\|display" | cut -d: -f3 | sed 's/^ //')
    else
        gpu="No disponible"
    fi
    
    # Procesos
    procesos=$(ps aux | wc -l)
    procesos_activos=$(ps aux | grep -v "PID" | wc -l)
    
    # Usuarios
    usuarios=$(who | wc -l)
    usuario_actual=$(whoami)
    
    # Compilar toda la información
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    INFORMACIÓN DEL SISTEMA                   ║"
    echo "╠══════════════════════════════════════════════════════════════╣"
    echo "║                                                            ║"
    echo "║  🖥️  SISTEMA OPERATIVO                                     ║"
    echo "║     Sistema: $os"
    echo "║     Hostname: $hostname"
    echo "║     Kernel: $kernel"
    echo "║     Tiempo activo: $uptime"
    echo "║                                                            ║"
    echo "║  🔧  PROCESADOR (CPU)                                      ║"
    echo "║     Modelo: $cpu_model"
    echo "║     Núcleos: $cpu_cores"
    echo "║     Uso: $cpu_usage%"
    echo "║     Temperatura: $temp_info"
    echo "║                                                            ║"
    echo "║  💾  MEMORIA RAM                                           ║"
    echo "║     Total: $mem_total"
    echo "║     Usado: $mem_used ($mem_percent%)"
    echo "║     Swap: $swap_used / $swap_total"
    echo "║                                                            ║"
    echo "║  💿  ALMACENAMIENTO                                        ║"
    echo "║     Disco (/: $disk_used / $disk_total ($disk_percent)"
    echo "║                                                            ║"
    echo "║  🌐  RED                                                   ║"
    echo "║     Interfaz: $interface"
    echo "║     IP: $ip_address"
    echo "║     WiFi: $wifi_ssid"
    echo "║                                                            ║"
    echo "║  🎮  GPU                                                   ║"
    echo "║     $gpu"
    echo "║                                                            ║"
    echo "║  👥  USUARIOS Y PROCESOS                                   ║"
    echo "║     Usuario actual: $usuario_actual"
    echo "║     Usuarios activos: $usuarios"
    echo "║     Procesos totales: $procesos"
    echo "║                                                            ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
}

# Verificar si YAD está instalado
if ! command -v yad &> /dev/null; then
    echo "Error: YAD no está instalado."
    echo "Instálalo con: sudo pacman -S yad"
    exit 1
fi

# Crear archivo temporal para la información
temp_file=$(mktemp)

# Obtener información y guardarla
get_system_info > "$temp_file"

# Mostrar ventana con YAD
yad --width=600 --height=500 \
    --title="Acerca de este equipo" \
    --window-icon="computer" \
    --text-info \
    --filename="$temp_file" \
    --fontname="Monospace 10" \
    --button="Cerrar:0" \
    --button="Refrescar:1" \
    --button="Exportar:2"

# Manejar la respuesta
response=$?
case $response in
    1) # Refrescar
        rm "$temp_file"
        exec "$0"
        ;;
    2) # Exportar
        save_file=$(yad --file --save --filename="system_info_$(date +%Y%m%d).txt")
        if [ -n "$save_file" ]; then
            cp "$temp_file" "$save_file"
            notify-send "Exportado" "Información guardada en $save_file"
        fi
        ;;
esac

# Limpiar archivo temporal
rm -f "$temp_file"