#!/bin/bash
# ============================================================================
# 🍎 Hyprland macOS Tahoe Setup - Installer
# ============================================================================
# Un comando para instalar un escritorio estilo macOS en Hyprland
# 
# Uso: bash install.sh
# ============================================================================

set -e

# ============================================================================
# Colores
# ============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ============================================================================
# Funciones auxiliares
# ============================================================================
print_logo() {
    echo -e "${CYAN}"
    echo "  ╔════════════════════════════════════════════════════════════╗"
    echo "  ║           🍎 Hyprland macOS Tahoe Setup 🍎                ║"
    echo "  ║                  Installer v1.0                          ║"
    echo "  ╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_step() {
    echo -e "\n${BLUE}[$1/10]${NC} ${GREEN}$2${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# ============================================================================
# Verificar sistema operativo
# ============================================================================
check_system() {
    print_step "1" "Verificando sistema operativo..."
    
    if [ -f /etc/arch-release ]; then
        DISTRO="arch"
        PKG_MANAGER="pacman"
        AUR_HELPER="yay"
        print_success "Arch Linux detectado"
    elif [ -f /etc/endeavouros-release ]; then
        DISTRO="endeavour"
        PKG_MANAGER="pacman"
        AUR_HELPER="yay"
        print_success "EndeavourOS detectado"
    elif [ -f /etc/manjaro-release ]; then
        DISTRO="manjaro"
        PKG_MANAGER="pacman"
        AUR_HELPER="yay"
        print_success "Manjaro detectado"
    else
        print_error "Distribución no soportada. Solo se soporta Arch/EndeavourOS/Manjaro"
        exit 1
    fi
    
    # Verificar que hay un AUR helper
    if ! command -v $AUR_HELPER &> /dev/null; then
        print_warning "No se encontró $AUR_HELPER. Instalando..."
        sudo pacman -S --noconfirm yay
    fi
}

# ============================================================================
# Instalar dependencias
# ============================================================================
install_dependencies() {
    print_step "2" "Instalando dependencias principales..."
    
    # Paquetes base
    BASE_PACKAGES=(
        "hyprland"
        "hyprpaper"
        "hypridle"
        "hyprlock"
        "xdg-desktop-portal-hyprland"
        "waybar"
        "kitty"
        "rofi-wayland"
        "wofi"
        "dolphin"
        "firefox"
        "git"
        "wget"
        "curl"
        "unzip"
        "base-devel"
        "zsh"
    )
    
    # Paquetes de theming
    THEMING_PACKAGES=(
        "qt5ct"
        "kvantum"
        "breeze-icons"
        "breeze"
        "adwaita-cursors"
        "xdg-utils"
        "mako"
        "swww"
        "grim"
        "slurp"
        "wl-clipboard"
        "polkit-gnome"
        "pavucontrol"
        "brightnessctl"
        "playerctl"
        "python-psutil"
    )
    
    # Instalar paquetes base
    for pkg in "${BASE_PACKAGES[@]}"; do
        if ! pacman -Qi $pkg &> /dev/null; then
            print_warning "Instalando $pkg..."
            sudo pacman -S --noconfirm $pkg
        fi
    done
    
    # Instalar paquetes de theming
    for pkg in "${THEMING_PACKAGES[@]}"; do
        if ! pacman -Qi $pkg &> /dev/null; then
            print_warning "Instalando $pkg..."
            sudo pacman -S --noconfirm $pkg
        fi
    done
    
    # Instalar qt6ct-kde desde AUR
    if ! pacman -Qi qt6ct-kde &> /dev/null; then
        print_warning "Instalando qt6ct-kde, eww, whitesur-theme desde AUR..."
        $AUR_HELPER -S --noconfirm qt6ct-kde eww whitesur-cursor-theme-git whitesur-icon-theme whitesur-gtk-theme-git
    fi
    
    print_success "Dependencias y temas instalados "
}



# ============================================================================
# Instalar tema Kvantum
# ============================================================================
install_kvantum() {
    print_step "4" "Configurando tema Kvantum..."
    
    KVANTUM_DIR="$HOME/.config/Kvantum"
    mkdir -p "$KVANTUM_DIR"
    
    # Descargar tema KvDark si no existe
    if [ ! -d "/usr/share/Kvantum/KvDark" ]; then
        print_warning "Descargando tema KvDark..."
        # KvDark ya viene con kvantum, solo verificar
        if pacman -Qi kvantum &> /dev/null; then
            print_success "KvDark ya está instalado con Kvantum"
        fi
    fi
    
    # Configurar Kvantum
    cat > "$KVANTUM_DIR/kvantum.conf" << EOF
[General]
theme=KvDark
EOF
    
    print_success "Tema Kvantum configurado"
}

# ============================================================================
# Instalar Quickshell
# ============================================================================
install_quickshell() {
    print_step "5" "Instalando Quickshell..."
    
    if ! command -v quickshell &> /dev/null; then
        print_warning "Instalando Quickshell..."
        $AUR_HELPER -S --noconfirm quickshell
    fi
    
    print_success "Quickshell instalado"
}

# ============================================================================
# Copiar configuraciones
# ============================================================================
copy_configs() {
    print_step "6" "Copiando configuraciones..."
    
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    CONFIG_SOURCE="$SCRIPT_DIR/config"
    
    # Backup de configuraciones existentes
    BACKUP_DIR="$HOME/.config/backup-hypr-macos-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    # Lista de directorios a copiar
    CONFIG_DIRS=(
        "hypr"
        "waybar"
        "kitty"
        "rofi"
        "eww"
        "quickshell"
        "dolphin"
        "qt6ct"
        "Kvantum"
        "xsettingsd"
        "System_Info"
    )
    
    for dir in "${CONFIG_DIRS[@]}"; do
        if [ -d "$HOME/.config/$dir" ]; then
            print_warning "Haciendo backup de $dir..."
            cp -r "$HOME/.config/$dir" "$BACKUP_DIR/"
        fi
        
        if [ -d "$CONFIG_SOURCE/$dir" ]; then
            print_warning "Copiando $dir..."
            mkdir -p "$HOME/.config/$dir"
            cp -r "$CONFIG_SOURCE/$dir"/* "$HOME/.config/$dir/"
        fi
    done
    
    # Copiar archivos individuales
    INDIVIDUAL_FILES=(
        "dolphinrc"
        "kdeglobals"
        "gtk-3.0/settings.ini"
        "gtk-4.0/settings.ini"
    )
    
    for file in "${INDIVIDUAL_FILES[@]}"; do
        if [ -f "$CONFIG_SOURCE/$file" ]; then
            print_warning "Copiando $file..."
            mkdir -p "$HOME/.config/$(dirname $file)"
            cp "$CONFIG_SOURCE/$file" "$HOME/.config/$file"
        fi
    done
    
    print_success "Configuraciones copiadas (backup en $BACKUP_DIR)"
}

# ============================================================================
# Configurar variables de entorno
# ============================================================================
setup_environment() {
    print_step "7" "Configurando variables de entorno..."
    
    # Crear archivo de variables de entorno
    ENV_FILE="$HOME/.config/hypr/env.conf"
    
    cat > "$ENV_FILE" << 'EOF'
# ============================================================================
# Variables de entorno para Hyprland macOS Setup
# ============================================================================

# Cursor
env = XCURSOR_THEME,WhiteSur-cursor
env = XCURSOR_SIZE,24
env = HYPRCURSOR_THEME,WhiteSur-cursor
env = HYPRCURSOR_SIZE,24

# GTK Theme
env = GTK_THEME,WhiteSur-dark
env = GDK_THEME,WhiteSur-dark

# Qt Theme
env = QT_QPA_PLATFORMTHEME,qt5ct
env = QT_STYLE_OVERRIDE,Breeze
env = QT_AUTO_SCREEN_SCALE_FACTOR,1

# XDG
env = XDG_CURRENT_DESKTOP,Hyprland:KDE
env = XDG_SESSION_TYPE,wayland

# Firefox Wayland
env = MOZ_ENABLE_WAYLAND,1
env = MOZ_USE_XINPUT2,1

# Java AWT
env = _JAVA_AWT_WM_NONREPARENTING,1

# SDL
env = SDL_VIDEODRIVER,wayland

# Clutter
env = CLUTTER_BACKEND,wayland
EOF
    
    print_success "Variables de entorno configuradas"
}

# ============================================================================
# Configurar autostart
# ============================================================================
setup_autostart() {
    print_step "8" "Configurando autostart..."
    
    # Verificar si hyprland.lua ya tiene autostart
    if ! grep -q "hyprland.start" "$HOME/.config/hypr/hyprland.lua" 2>/dev/null; then
        print_warning "Configurando autostart en hyprland.lua..."
        
        # Agregar sección de autostart si no existe
        cat >> "$HOME/.config/hypr/hyprland.lua" << 'EOF'

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("eww daemon")
    hl.exec_cmd("qs")
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("pkill -f hyprland/macos_dock_state.sh; bash ~/.config/hypr/scripts/macos_dock_state.sh")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-dark'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface icon-theme 'WhiteSur-dark'")
    hl.exec_cmd("gsettings set org.gnome.desktop.cursor-theme 'WhiteSur-cursor'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size 24")
end)
EOF
    fi
    
    print_success "Autostart configurado"
}

# ============================================================================
# Configurar Hyprland
# ============================================================================
setup_hyprland() {
    print_step "9" "Configurando Hyprland..."
    
    HYPRLAND_CONF="$HOME/.config/hypr/hyprland.lua"
    
    # Verificar si el archivo principal existe
    if [ ! -f "$HYPRLAND_CONF" ]; then
        print_error "No se encontró hyprland.lua"
        print_warning "Asegúrate de que el repositorio tiene el archivo config/hypr/hyprland.lua"
        exit 1
    fi
    
    # Verificar que tiene la sección de plugin hyprbars
    if ! grep -q "hyprbars" "$HYPRLAND_CONF"; then
        print_warning "Agregando configuración de hyprbars..."
        
        cat >> "$HYPRLAND_CONF" << 'EOF'

-----------------------
---- PLUGINS ----------
-----------------------

-- hyprbars: barra de título compositor-side con botones tipo semáforo.
hl.config({
    plugin = {
        hyprbars = {
            bar_height              = 28,
            bar_color                = "rgba(40,40,42,0.75)",
            bar_blur                 = true,
            col = { text = "rgba(230,230,235,1.0)" },
            bar_title_enabled        = true,
            bar_text_size            = 12,
            bar_text_weight          = "semibold",
            bar_text_font            = "SF Pro Display",
            bar_text_align           = "center",
            bar_buttons_alignment    = "left",
            bar_part_of_window       = true,
            bar_precedence_over_border = true,
            bar_padding              = 10,
            bar_button_padding       = 6,
            icon_on_hover             = true,
            inactive_button_color    = "rgba(255,255,255,0.15)",
        },
    },
})

-- Botones estilo macOS
hl.plugin.hyprbars.add_button({
    bg_color = "rgb(ff5f57)",
    fg_color = "rgb(4d0000)",
    size     = 15,
    icon     = "✕",
    action   = "hyprctl dispatch 'hl.dsp.window.close()'",
})
hl.plugin.hyprbars.add_button({
    bg_color = "rgb(febc2e)",
    fg_color = "rgb(4d3900)",
    size     = 15,
    icon     = "–",
    action   = "bash ~/.config/hypr/scripts/macos_minimize.sh",
})
hl.plugin.hyprbars.add_button({
    bg_color = "rgb(28c840)",
    fg_color = "rgb(003d0a)",
    size     = 15,
    icon     = "⤢",
    action   = "bash ~/.config/hypr/scripts/macos_fullscreen.sh",
})
EOF
    fi
    
    print_success "Hyprland configurado"
}

# ============================================================================
# Configurar Waybar
# ============================================================================
setup_waybar() {
    print_step "10" "Configurando Waybar..."
    
    WAYBAR_DIR="$HOME/.config/waybar"
    mkdir -p "$WAYBAR_DIR"
    
    # Verificar si waybar.jsonc existe
    if [ ! -f "$WAYBAR_DIR/config.jsonc" ]; then
        print_warning "Creando configuración de Waybar..."
        
        cat > "$WAYBAR_DIR/config.jsonc" << 'EOF'
{
    "layer": "top",
    "position": "top",
    "height": 28,
    "spacing": 0,
    "modules-left": [
        "custom/apple",
        "custom/minimized",
        "hyprland/window"
    ],
    "modules-center": [
        "clock"
    ],
    "modules-right": [
        "tray",
        "pulseaudio",
        "network",
        "battery",
        "custom/control-center"
    ],
    "custom/apple": {
        "format": "",
        "tooltip": false,
        "on-click": "~/.config/eww/scripts/toogle_apple_menu.sh"
    },
    "custom/minimized": {
        "exec": "~/.config/waybar/minimized_apps.sh",
        "return-type": "json",
        "interval": 2,
        "signal": 8,
        "format": "{}",
        "max-length": 32,
        "tooltip": true,
        "on-click": "~/.config/waybar/minimized_apps.sh --restore"
    },
    "hyprland/window": {
        "format": "  {}",
        "max-length": 24,
        "separate-outputs": true,
        "tooltip": false
    },
    "clock": {
        "format": "{:%a %b %d  %H:%M}",
        "tooltip-format": "<tt><small>{calendar}</small></tt>"
    },
    "network": {
        "format-wifi": " {signalStrength}%",
        "format-ethernet": "󰈀",
        "format-disconnected": "󰖪",
        "tooltip-format": "{essid} ({signalStrength}%)"
    },
    "pulseaudio": {
        "format": " {volume}%",
        "format-muted": "󰖁",
        "on-click": "pavucontrol"
    },
    "battery": {
        "states": {
            "warning": 30,
            "critical": 15
        },
        "format": "{capacity}% {icon}",
        "format-charging": "{capacity}% ",
        "format-icons": ["", "", "", "", ""]
    },
    "custom/control-center": {
        "format": "   ",
        "tooltip": false,
        "on-click": "~/.config/eww/scripts/toogle_control_center.sh"
    }
}
EOF
    fi
    
    print_success "Waybar configurado"
}

# ============================================================================
# Finalización
# ============================================================================
finish_installation() {
    echo -e "\n${GREEN}"
    echo "  ╔════════════════════════════════════════════════════════════╗"
    echo "  ║           🍎 Instalación Completada 🍎                    ║"
    echo "  ╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo -e "${CYAN}Próximos pasos:${NC}"
    echo -e "  1. ${YELLOW}Reiniciar sesión de Hyprland${NC}"
    echo -e "  2. ${YELLOW}Cerrar y volver a abrir las aplicaciones${NC}"
    echo -e "  3. ${YELLOW}Verificar que los temas estén aplicados${NC}"
    echo ""
    echo -e "${CYAN}Comandos útiles:${NC}"
    echo -e "  • ${GREEN}Reiniciar Hyprland:${NC} Super + Ctrl + Q"
    echo -e "  • ${GREEN}Abrir terminal:${NC} Super + Q"
    echo -e "  • ${GREEN}Abrir file manager:${NC} Super + E"
    echo -e "  • ${GREEN}Menu de aplicaciones:${NC} Super + Space"
    echo ""
    echo -e "${CYAN}Archivos de configuración:${NC}"
    echo -e "  • ${GREEN}Hyprland:${NC} ~/.config/hypr/hyprland.lua"
    echo -e "  • ${GREEN}Waybar:${NC} ~/.config/waybar/"
    echo -e "  • ${GREEN}Kitty:${NC} ~/.config/kitty/kitty.conf"
    echo -e "  • ${GREEN}EWW:${NC} ~/.config/eww/"
    echo ""
    echo -e "${CYAN}Documentación:${NC}"
    echo -e "  • ${GREEN}GitHub:${NC} https://github.com/tu-usuario/hyprland-macos-setup"
    echo -e "  • ${GREEN}Issues:${NC} https://github.com/tu-usuario/hyprland-macos-setup/issues"
    echo ""
    echo -e "${YELLOW}¡Disfruta de tu escritorio estilo macOS! 🍎${NC}"
}

# ============================================================================
# Main
# ============================================================================
main() {
    print_logo
    
    echo -e "${CYAN}Este script instalará un escritorio Hyprland estilo macOS Tahoe.${NC}"
    echo -e "${CYAN}Se instalarán los siguientes componentes:${NC}"
    echo -e "  • ${GREEN}Hyprland${NC} - Window manager"
    echo -e "  • ${GREEN}Waybar${NC} - Barra de estado"
    echo -e "  • ${GREEN}Kitty${NC} - Terminal"
    echo -e "  • ${GREEN}EWW${NC} - Widgets"
    echo -e "  • ${GREEN}Rofi${NC} - Menu de aplicaciones"
    echo -e "  • ${GREEN}Dolphin${NC} - File manager"
    echo -e "  • ${GREEN}WhiteSur${NC} - Tema macOS"
    echo -e "  • ${GREEN}Quickshell${NC} - Centro de control"
    echo ""
    
    read -p "¿Continuar con la instalación? (s/n): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        echo -e "${RED}Instalación cancelada.${NC}"
        exit 1
    fi
    
    check_system
    install_dependencies
    install_whitesur
    install_kvantum
    install_quickshell
    copy_configs
    setup_environment
    setup_autostart
    setup_hyprland
    setup_waybar
    finish_installation
}

# Ejecutar main
main "$@"
