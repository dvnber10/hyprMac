#!/bin/bash
# run.sh - Lanzador con verificación de entorno

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Verificar si el entorno virtual existe
if [ ! -d "venv" ]; then
    echo "❌ Entorno virtual no encontrado. Creando uno..."
    python -m venv venv
    source venv/bin/activate
    pip install --upgrade pip
    pip install PyQt5 psutil matplotlib PyQtChart
    echo "✅ Entorno virtual creado e instalado"
else
    source venv/bin/activate
fi

# Verificar dependencias
python -c "import PyQt5, psutil, matplotlib" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "⚠️  Faltan dependencias. Instalando..."
    pip install PyQt5 psutil matplotlib
fi

# Ejecutar la aplicación
echo "🚀 Iniciando System Monitor..."
python3 main.py

# Salir del entorno virtual
deactivate