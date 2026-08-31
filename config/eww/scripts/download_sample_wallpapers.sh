#!/bin/bash
# ============================================================
# download_sample_wallpapers.sh — Descarga wallpapers de ejemplo
# ============================================================

WALLPAPER_DIR="$HOME/.config/eww/wallpapers/images"

echo "📥 Descargando wallpapers de ejemplo..."

# Wallpapers populares de Unsplash (direct link)
URLS=(
    "https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=1920&q=80"
    "https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=1920&q=80"
    "https://images.unsplash.com/photo-1472214103451-9374bd1c798e?w=1920&q=80"
    "https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=1920&q=80"
    "https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=1920&q=80"
    "https://images.unsplash.com/photo-1473448912268-2022ce9509d8?w=1920&q=80"
    "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=1920&q=80"
    "https://images.unsplash.com/photo-1519681393784-d120267933ba?w=1920&q=80"
    "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=1920&q=80"
    "https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?w=1920&q=80"
)

NAMES=(
    "bosque Niebla"
    "lago Montañas"
    "campo Verde"
    "valle Sol"
    "bosque Seco"
    "bosque Otoñal"
    "playa Tropical"
    "montañas Noche"
    "montaña Pico"
    "colinas Verdes"
)

for i in "${!URLS[@]}"; do
    NAME="${NAMES[$i]}.jpg"
    if [ ! -f "$WALLPAPER_DIR/$NAME" ]; then
        echo "  → Descargando: $NAME"
        curl -sL -o "$WALLPAPER_DIR/$NAME" "${URLS[$i]}"
    else
        echo "  ✓ Ya existe: $NAME"
    fi
done

echo ""
echo "✅ ¡Listo! Se descargaron ${#URLS[@]} wallpapers en:"
echo "   $WALLPAPER_DIR"
echo ""
echo "💡 Usa 'Super + P' o el menú de Apple para cambiar el fondo."
