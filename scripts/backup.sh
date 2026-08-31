#!/bin/bash
# ============================================================================
# 🍎 Hyprland macOS Setup - Backup Script
# ============================================================================
# Crea un backup de todas las configuraciones actuales
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
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_NAME="backup-$TIMESTAMP"
BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"

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

# ============================================================================
# Main
# ============================================================================
main() {
    echo -e "${BLUE}"
    echo "  ╔════════════════════════════════════════════════════════════╗"
    echo "  ║           🍎 Backup de Configuraciones 🍎                 ║"
    echo "  ╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # Crear directorio de backup
    print_step "1" "Creando directorio de backup..."
    mkdir -p "$BACKUP_PATH"
    
    # Backup de Hyprland
    print_step "2" "Haciendo backup de Hyprland..."
    if [ -d "$HOME/.config/hypr" ]; then
        cp -r "$HOME/.config/hypr" "$BACKUP_PATH/"
        print_success "Hyprland respaldado"
    fi
    
    # Backup de Waybar
    print_step "3" "Haciendo backup de Waybar..."
    if [ -d "$HOME/.config/waybar" ]; then
        cp -r "$HOME/.config/waybar" "$BACKUP_PATH/"
        print_success "Waybar respaldado"
    fi
    
    # Backup de Kitty
    print_step "4" "Haciendo backup de Kitty..."
    if [ -d "$HOME/.config/kitty" ]; then
        cp -r "$HOME/.config/kitty" "$BACKUP_PATH/"
        print_success "Kitty respaldado"
    fi
    
    # Backup de otros archivos
    print_step "5" "Haciendo backup de otros archivos..."
    OTHER_FILES=(
        "dolphinrc"
        "kdeglobals"
        "gtk-3.0"
        "gtk-4.0"
        "qt6ct"
        "Kvantum"
    )
    
    for file in "${OTHER_FILES[@]}"; do
        if [ -e "$HOME/.config/$file" ]; then
            cp -r "$HOME/.config/$file" "$BACKUP_PATH/"
        fi
    done
    print_success "Otros archivos respaldados"
    
    # Crear archivo de información
    print_step "6" "Creando archivo de información..."
    cat > "$BACKUP_PATH/backup-info.txt" << EOF
Backup created: $(date)
Hostname: $(hostname)
User: $(whoami)
Hyprland version: $(hyprctl version 2>/dev/null | head -1 || echo "N/A")
EOF
    
    print_success "Backup completado en: $BACKUP_PATH"
    
    echo -e "\n${GREEN}Backup guardado en:${NC}"
    echo -e "  ${YELLOW}$BACKUP_PATH${NC}"
    echo -e "\n${GREEN}Para restaurar:${NC}"
    echo -e "  ${YELLOW}bash restore.sh $BACKUP_NAME${NC}"
}

# Ejecutar main
main "$@"
