#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
generate_document.py
=====================================================================
Convierte CUALQUIER archivo a CUALQUIER formato usando LibreOffice en
modo headless (sin abrir la interfaz grafica), desde Python.

Sirve para que una persona -o una IA- pueda:
  1. Crear un archivo fuente con Python (docx, pptx, xlsx, html, csv...).
  2. Convertirlo al formato final (PDF, DOCX, PPTX, XLSX, HTML...) con
     este script.

La salida SIEMPRE se guarda en:  docs/generated_docs/

---------------------------------------------------------------------
USO DESDE LA TERMINAL
---------------------------------------------------------------------
    python scripts/generate_document.py <archivo_entrada> [formato_salida]

Ejemplos:
    python scripts/generate_document.py reporte.html pdf
    python scripts/generate_document.py reporte.docx pdf
    python scripts/generate_document.py datos.xlsx  csv
    python scripts/generate_document.py slides.pptx pdf

(Si no pones formato_salida, por defecto es "pdf".)

---------------------------------------------------------------------
USO DESDE OTRO SCRIPT DE PYTHON
---------------------------------------------------------------------
    from scripts.generate_document import convertir
    convertir("reporte.docx", "pdf")

---------------------------------------------------------------------
FORMATOS DE SALIDA MAS USADOS (parametro formato_salida)
---------------------------------------------------------------------
    pdf    -> documento PDF
    docx   -> Word
    pptx   -> PowerPoint
    xlsx   -> Excel
    csv    -> CSV (desde una hoja de calculo)
    html   -> pagina web
    odt / odp / ods -> formatos abiertos de LibreOffice
    txt    -> texto plano
=====================================================================
"""
from __future__ import annotations

import os
import shutil
import subprocess
import sys

# Carpeta de salida fija: docs/generated_docs/ (relativa a la raiz del repo)
REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT_DIR = os.path.join(REPO_ROOT, "docs", "generated_docs")


def _buscar_soffice() -> str:
    """Devuelve la ruta al ejecutable de LibreOffice o termina con error claro."""
    # 1) Buscar en el PATH (Linux / macOS / Windows con winget)
    for nombre in ("soffice", "libreoffice", "soffice.exe"):
        ruta = shutil.which(nombre)
        if ruta:
            return ruta
    # 2) Ruta tipica en macOS
    mac = "/Applications/LibreOffice.app/Contents/MacOS/soffice"
    if os.path.exists(mac):
        return mac
    # 3) Ruta tipica en Windows
    win = r"C:\Program Files\LibreOffice\program\soffice.exe"
    if os.path.exists(win):
        return win
    raise FileNotFoundError(
        "LibreOffice no esta instalado.\n"
        "Instalalo primero con:  bash scripts/setup_libreoffice.sh"
    )


def convertir(archivo_entrada: str, formato_salida: str = "pdf") -> str:
    """
    Convierte 'archivo_entrada' al 'formato_salida' y lo guarda en
    docs/generated_docs/. Devuelve la ruta del archivo generado.
    """
    if not os.path.isfile(archivo_entrada):
        raise FileNotFoundError(f"No existe el archivo de entrada: {archivo_entrada}")

    soffice = _buscar_soffice()
    os.makedirs(OUT_DIR, exist_ok=True)

    base = os.path.splitext(os.path.basename(archivo_entrada))[0]
    salida = os.path.join(OUT_DIR, f"{base}.{formato_salida}")
    # Si ya existe una version previa, la quitamos para poder detectar si la
    # conversion realmente genero un archivo nuevo (LibreOffice a veces devuelve
    # exito aunque no exista un filtro de exportacion valido).
    if os.path.exists(salida):
        os.remove(salida)

    print(f"==> Convirtiendo '{archivo_entrada}' -> .{formato_salida}")
    proc = subprocess.run(
        [soffice, "--headless", "--convert-to", formato_salida, "--outdir", OUT_DIR, archivo_entrada],
        capture_output=True,
        text=True,
    )

    # LibreOffice puede terminar con codigo 0 aun cuando falla; por eso NO
    # confiamos solo en el codigo de salida: verificamos que el archivo exista.
    if not os.path.exists(salida):
        detalle = (proc.stderr or proc.stdout or "").strip()
        raise RuntimeError(
            f"La conversion a '.{formato_salida}' no produjo ningun archivo.\n"
            f"Detalle de LibreOffice: {detalle}\n"
            f"Sugerencia: no todas las combinaciones origen->destino son validas.\n"
            f"Por ejemplo, HTML convierte bien a PDF, pero para Word/PowerPoint/Excel\n"
            f"conviene CREAR el archivo con Python (python-docx/pptx, openpyxl/pandas)\n"
            f"y usar este conversor solo para pasarlo a PDF. Ver scripts/README.md."
        )

    print(f"==> Documento generado en: {salida}")
    return salida


def _main() -> None:
    if len(sys.argv) < 2:
        print("Uso: python scripts/generate_document.py <archivo_entrada> [formato_salida]", file=sys.stderr)
        sys.exit(1)
    entrada = sys.argv[1]
    formato = sys.argv[2] if len(sys.argv) > 2 else "pdf"
    try:
        convertir(entrada, formato)
    except (FileNotFoundError, subprocess.CalledProcessError) as e:
        print(f"ERROR: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    _main()
