#!/usr/bin/env bash
# =============================================================================
# generate_document.sh
# -----------------------------------------------------------------------------
# Convierte CUALQUIER archivo a CUALQUIER formato usando LibreOffice en modo
# headless (sin abrir la interfaz grafica). La salida se guarda en:
#     docs/generated_docs/
#
# Uso:
#   bash scripts/generate_document.sh <archivo_entrada> [formato_salida]
#
# Ejemplos:
#   bash scripts/generate_document.sh reporte.html pdf
#   bash scripts/generate_document.sh reporte.docx pdf
#   bash scripts/generate_document.sh datos.xlsx    csv
#   bash scripts/generate_document.sh slides.pptx   pdf
#
# formato_salida por defecto: pdf
# Formatos de salida usuales: pdf docx pptx xlsx csv html odt odp ods txt
# =============================================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="$REPO_ROOT/docs/generated_docs"

if [ "$#" -lt 1 ]; then
  echo "Uso: bash scripts/generate_document.sh <archivo_entrada> [formato_salida]" >&2
  exit 1
fi

INPUT="$1"
FORMAT="${2:-pdf}"

if [ ! -f "$INPUT" ]; then
  echo "ERROR: No existe el archivo de entrada: $INPUT" >&2
  exit 1
fi

# Resolver el ejecutable de LibreOffice (PATH o ruta tipica en macOS)
SOFFICE=""
if command -v soffice >/dev/null 2>&1; then
  SOFFICE="soffice"
elif [ -x "/Applications/LibreOffice.app/Contents/MacOS/soffice" ]; then
  SOFFICE="/Applications/LibreOffice.app/Contents/MacOS/soffice"
else
  echo "ERROR: LibreOffice no esta instalado. Corre primero: bash scripts/setup_libreoffice.sh" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"

# Nombre esperado del archivo de salida (mismo nombre base, nueva extension)
BASE="$(basename "${INPUT%.*}")"
EXPECTED="$OUT_DIR/$BASE.$FORMAT"
# Borramos una version previa para poder detectar si SI se genero algo nuevo.
rm -f "$EXPECTED"

echo "==> Convirtiendo '$INPUT' -> .$FORMAT"
"$SOFFICE" --headless --convert-to "$FORMAT" --outdir "$OUT_DIR" "$INPUT"

# LibreOffice a veces devuelve exito aunque falle; verificamos el archivo real.
if [ ! -f "$EXPECTED" ]; then
  echo "ERROR: La conversion a '.$FORMAT' no produjo ningun archivo." >&2
  echo "       No todas las combinaciones origen->destino son validas." >&2
  echo "       HTML convierte bien a PDF; para Word/PowerPoint/Excel conviene" >&2
  echo "       CREARLOS con Python y usar este conversor solo para pasarlos a PDF." >&2
  echo "       Ver scripts/README.md" >&2
  exit 1
fi

echo "==> Documento generado en: $EXPECTED"
