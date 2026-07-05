# Documentación generada

En esta carpeta caen **todos los documentos generados** (PDF, DOCX, PPTX, XLSX,
CSV, HTML…) creados con Python + LibreOffice.

## ¿Cómo genero un documento aquí?

👉 **Guía completa paso a paso (en español):** [`scripts/README.md`](../../scripts/README.md)

Resumen rápido:

```bash
# 1) Instalar todo una sola vez
bash scripts/setup_libreoffice.sh
pip install -r requirements.txt

# 2) Convertir cualquier archivo al formato que quieras (cae en esta carpeta)
python scripts/generate_document.py <archivo_entrada> <formato_salida>
# ej: python scripts/generate_document.py reporte.html pdf
```

> Nota: los archivos de esta carpeta son **artefactos reproducibles**. No los
> edites a mano; edita la fuente y vuelve a generarlos.
