#!/bin/bash
# ============================================================================
# 🍎 Hyprland macOS Setup - Switch Version
# ============================================================================
# Cambia entre la versión con plugins y sin plugins
# ============================================================================

set -e

# ============================================================================
# Colores
# ============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ============================================================================
# Configuración
# ============================================================================
HYPRLAND_DIR="$HOME/.config/hypr"
HYPRLAND_CONF="$HYPRLAND_DIR/hyprland.lua"
HYPRLAND_WITH_PLUGINS="$HYPRLAND_DIR/hyprland-with-plugins.lua"
HYPRLAND_NO_PLUGINS="$HYPRLAND_DIR/hyprland-no-plugins.lua"

# ============================================================================
# Funciones
# ============================================================================
print_step() {
    echo -e "${BLUE}[$1/3]${NC} ${GREEN}$2${NC}"
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
# Main
# ============================================================================
main() {
    echo -e "${BLUE}"
    echo "  ╔════════════════════════════════════════════════════════════╗"
    echo "  ║           🍎 Cambiar Versión de Hyprland 🍎               ║"
    echo "  ╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo -e "${GREEN}Versiones disponibles:${NC}"
    echo -e "  ${YELLOW}1${NC}. Versión CON plugins (hyprbars) - Botones de semáforo"
    echo -e "  ${YELLOW}2${NC}. Versión SIN plugins - Decoración nativa"
    echo ""
    
    read -p "Selecciona una opción (1 o 2): " choice
    
    case $choice in
        1)
            print_step "1" "Cambiando a versión CON plugins..."
            
            # Verificar que hyprbars esté instalado
            if ! hyprpm list 2>/dev/null | grep -q "hyprbars"; then
                print_warning "hyprbars no está instalado. Instalando..."
                sudo pacman -S --noconfirm hyprpm
                hyprpm add https://github.com/hyprwm/hyprland-plugins
                hyprpm enable hyprbars
            fi
            
            # Copiar configuración con plugins
            if [ -f "$HYPRLAND_WITH_PLUGINS" ]; then
                cp "$HYPRLAND_WITH_PLUGINS" "$HYPRLAND_CONF"
                print_success "Configuración con plugins activada"
            else
                print_error "No se encontró hyprland-with-plugins.lua"
                exit 1
            fi
            ;;
        2)
            print_step "1" "Cambiando a versión SIN plugins..."
            
            # Guardar configuración actual si tiene plugins
            if [ -f "$HYPRLAND_CONF" ] && grep -q "hyprbars" "$HYPRLAND_CONF"; then
                cp "$HYPRLAND_CONF" "$HYPRLAND_WITH_PLUGINS"
                print_warning "Configuración con plugins guardada"
            fi
            
            # Copiar configuración sin plugins
            if [ -f "$HYPRLAND_NO_PLUGINS" ]; then
                cp "$HYPRLAND_NO_PLUGINS" "$HYPRLAND_CONF"
                print_success "Configuración sin plugins activada"
            else
                print_error "No se encontró hyprland-no-plugins.lua"
                exit 1
            fi
            ;;
        *)
            print_error "Opción inválida"
            exit 1
            ;;
    esac
    
    print_step "2" "Reiniciando Hyprland..."
    hyprctl reload 2>/dev/null || true
    
    print_step "3" "Configuración actualizada"
    
    echo -e "\n${GREEN}"
    echo "  ╔════════════════════════════════════════════════════════════╗"
    echo "  ║           🍎 Versión Cambiada 🍎                         ║"
    echo "  ╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    if [ "$choice" = "1" ]; then
        echo -e "${GREEN}Versión activa:${NC} CON plugins (hyprbars)"
        echo -e "${YELLOW}Características:${NC}"
        echo -e "  • Botones de semáforo (🔴🟡🟢)"
        echo -e "  • Barra de título estilo macOS"
        echo -e "  • Botones personalizados"
    else
        echo -e "${GREEN}Versión activa:${NC} SIN plugins"
        echo -e "${YELLOW}Características:${NC}"
        echo -e "  • Decoración nativa de Hyprland"
        echo -e "  • Funciona sin plugins adicionales"
        echo -e "  • Más compatible"
    fi
    
    echo -e "\n${YELLOW}Reinicia sesión para ver los cambios.${NC}"
}

# Ejecutar main
main "$@"
