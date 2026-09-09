#!/bin/bash

# Directorio de wallpapers
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"  # Cambia esto a tu ruta

# Obtener lista de imágenes
mapfile -t wallpapers < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.bmp" \))

# Si no hay wallpapers, salir
if [ ${#wallpapers[@]} -eq 0 ]; then
    echo "No se encontraron wallpapers en $WALLPAPER_DIR"
    exit 1
fi

# Función para obtener el nombre del archivo sin ruta
get_name() {
    basename "$1"
}

# Función para obtener el directorio
get_dir() {
    dirname "$1"
}

# Crear lista para rofi con nombres formateados
rofi_list=""
for wp in "${wallpapers[@]}"; do
    name=$(get_name "$wp")
    rofi_list+="$name\n"
done

# Mostrar en rofi y obtener selección
selected=$(echo -e "$rofi_list" | rofi -dmenu \
    -i \
    -p "🎨 Wallpapers" \
    -theme-str 'window {width: 800px; height: 600px;}' \
    -theme-str 'element-icon {size: 400px;}' \
    -theme-str 'element-text {enabled: false;}' \
    -theme-str 'element {padding: 20px;}' \
    -theme-str 'listview {lines: 1; columns: 1;}' \
    -theme-str 'mainbox {children: [ inputbar, listview ];}' \
    -theme-str 'inputbar {children: [ prompt, entry ];}' \
    -theme-str 'prompt {text: "🎨";}' \
    -theme-str 'entry {placeholder: "Buscar wallpaper...";}')

# Si se seleccionó algo, aplicar el wallpaper
if [ -n "$selected" ]; then
    # Encontrar la ruta completa del wallpaper seleccionado
    for wp in "${wallpapers[@]}"; do
        if [ "$(get_name "$wp")" = "$selected" ]; then
            selected_wp="$wp"
            break
        fi
    done
    
    if [ -n "$selected_wp" ]; then
        # Aplicar wallpaper (ejemplo con feh)
        feh --bg-scale "$selected_wp"
        # O si usas nitrogen: nitrogen --set-zoom-fill "$selected_wp"
        # O para sway/i3: swaymsg output "*" bg "$selected_wp" fill
        
        echo "Wallpaper aplicado: $selected_wp"
    fi
fi