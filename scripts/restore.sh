#!/bin/bash
# ============================================================================
# 🍎 Hyprland macOS Setup - Restore Script
# ============================================================================
# Restaura configuraciones desde un backup
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
BACKUP_DIR="$HOME/.config/backup-hypr-macos"

# ============================================================================
# Funciones
# ============================================================================
print_step() {
    echo -e "${BLUE}[$1/6]${NC} ${GREEN}$2${NC}"
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
    echo "  ║           🍎 Restaurar Configuraciones 🍎                 ║"
    echo "  ╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # Verificar si hay backups disponibles
    if [ ! -d "$BACKUP_DIR" ]; then
        print_error "No se encontraron backups en: $BACKUP_DIR"
        echo -e "\n${YELLOW}Ejecuta backup.sh primero para crear un backup.${NC}"
        exit 1
    fi
    
    # Listar backups disponibles
    echo -e "${GREEN}Backups disponibles:${NC}"
    echo ""
    
    backups=($(ls -1 "$BACKUP_DIR" | sort -r))
    
    if [ ${#backups[@]} -eq 0 ]; then
        print_error "No se encontraron backups"
        exit 1
    fi
    
    for i in "${!backups[@]}"; do
        echo -e "  ${YELLOW}$((i+1))${NC}. ${backups[$i]}"
    done
    
    echo ""
    read -p "Selecciona un backup (número): " choice
    
    # Validar selección
    if [[ ! "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt ${#backups[@]} ]; then
        print_error "Selección inválida"
        exit 1
    fi
    
    BACKUP_NAME="${backups[$((choice-1))]}"
    BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"
    
    echo -e "\n${YELLOW}Restaurando backup: $BACKUP_NAME${NC}"
    echo ""
    
    # Restaurar Hyprland
    print_step "1" "Restaurando Hyprland..."
    if [ -d "$BACKUP_PATH/hypr" ]; then
        rm -rf "$HOME/.config/hypr"
        cp -r "$BACKUP_PATH/hypr" "$HOME/.config/"
        print_success "Hyprland restaurado"
    fi
    
    # Restaurar Waybar
    print_step "2" "Restaurando Waybar..."
    if [ -d "$BACKUP_PATH/waybar" ]; then
        rm -rf "$HOME/.config/waybar"
        cp -r "$BACKUP_PATH/waybar" "$HOME/.config/"
        print_success "Waybar restaurado"
    fi
    
    # Restaurar Kitty
    print_step "3" "Restaurando Kitty..."
    if [ -d "$BACKUP_PATH/kitty" ]; then
        rm -rf "$HOME/.config/kitty"
        cp -r "$BACKUP_PATH/kitty" "$HOME/.config/"
        print_success "Kitty restaurado"
    fi
    
    # Restaurar otros archivos
    print_step "4" "Restaurando otros archivos..."
    OTHER_ITEMS=(
        "dolphinrc"
        "kdeglobals"
        "gtk-3.0"
        "gtk-4.0"
        "qt6ct"
        "Kvantum"
    )
    
    for item in "${OTHER_ITEMS[@]}"; do
        if [ -e "$BACKUP_PATH/$item" ]; then
            rm -rf "$HOME/.config/$item"
            cp -r "$BACKUP_PATH/$item" "$HOME/.config/"
        fi
    done
    print_success "Otros archivos restaurados"
    
    # Reiniciar Hyprland
    print_step "5" "Reiniciando Hyprland..."
    if command -v hyprctl &> /dev/null; then
        hyprctl reload 2>/dev/null || true
        print_success "Hyprland reiniciado"
    fi
    
    # Finalizar
    print_step "6" "Restauración completada"
    
    echo -e "\n${GREEN}"
    echo "  ╔════════════════════════════════════════════════════════════╗"
    echo "  ║           🍎 Restauración Completada 🍎                   ║"
    echo "  ╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo -e "${GREEN}Backup restaurado:${NC} $BACKUP_NAME"
    echo -e "\n${YELLOW}Recomendaciones:${NC}"
    echo -e "  1. Cerrar y volver a abrir las aplicaciones"
    echo -e "  2. Reiniciar Hyprland si es necesario"
    echo -e "  3. Verificar que todo funciona correctamente"
}

# Ejecutar main
main "$@"
