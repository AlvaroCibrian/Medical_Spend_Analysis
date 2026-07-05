#!/usr/bin/env bash
# =============================================================================
# setup_libreoffice.sh
# -----------------------------------------------------------------------------
# Instala LibreOffice para que cualquier colaborador del repo pueda generar
# y convertir documentacion (Markdown/HTML/ODT/DOCX -> PDF/DOCX) en modo
# headless (sin abrir la interfaz grafica).
#
# LibreOffice NO se versiona dentro del repo (el binario pesa ~1 GB); en su
# lugar este script lo instala de forma reproducible en cada maquina.
#
# Uso:
#   bash scripts/setup_libreoffice.sh
# =============================================================================
set -euo pipefail

echo "==> Verificando si LibreOffice ya esta instalado..."
if command -v soffice >/dev/null 2>&1 || [ -d "/Applications/LibreOffice.app" ]; then
  echo "    LibreOffice ya esta disponible. Nada que hacer."
  soffice --headless --version 2>/dev/null || \
    /Applications/LibreOffice.app/Contents/MacOS/soffice --headless --version 2>/dev/null || true
  exit 0
fi

OS="$(uname -s)"
case "$OS" in
  Darwin)
    echo "==> macOS detectado. Instalando via Homebrew..."
    if ! command -v brew >/dev/null 2>&1; then
      echo "ERROR: Homebrew no esta instalado. Instalalo desde https://brew.sh y vuelve a correr este script." >&2
      exit 1
    fi
    brew install --cask libreoffice
    ;;
  Linux)
    echo "==> Linux detectado. Instalando con el gestor de paquetes disponible..."
    if   command -v apt-get >/dev/null 2>&1; then sudo apt-get update && sudo apt-get install -y libreoffice
    elif command -v dnf     >/dev/null 2>&1; then sudo dnf install -y libreoffice
    elif command -v pacman  >/dev/null 2>&1; then sudo pacman -S --noconfirm libreoffice-fresh
    else
      echo "ERROR: No se encontro apt/dnf/pacman. Instala LibreOffice manualmente: https://www.libreoffice.org/download" >&2
      exit 1
    fi
    ;;
  MINGW*|MSYS*|CYGWIN*)
    echo "==> Windows detectado."
    echo "    Instala LibreOffice con:  winget install TheDocumentFoundation.LibreOffice"
    echo "    o descargalo desde:       https://www.libreoffice.org/download"
    exit 0
    ;;
  *)
    echo "ERROR: SO no reconocido ($OS). Descarga LibreOffice desde https://www.libreoffice.org/download" >&2
    exit 1
    ;;
esac

echo "==> Instalacion completada. Verificando..."
soffice --headless --version
echo "==> Listo. Ya puedes generar documentacion con: bash scripts/generate_document.sh <archivo>"
