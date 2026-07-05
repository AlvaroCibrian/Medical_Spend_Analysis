# 📄 Guía: Generar documentos (PDF, Word, PowerPoint, Excel, CSV, HTML…)

Esta guía explica **paso a paso y en español** cómo generar documentos en
**cualquier formato** dentro de este proyecto, usando **Python + LibreOffice**.

Está escrita para que **cualquier persona o cualquier IA** pueda seguirla sin
perderse. Si eres una IA leyendo esto: sigue exactamente los pasos de abajo.

---

## 🧠 La idea en 10 segundos

Generar un documento se hace en **2 pasos**:

1. **CREAR** el archivo fuente con Python
   (por ejemplo un `.docx`, `.pptx`, `.xlsx`, `.html` o `.csv`).
2. **CONVERTIR** ese archivo al formato final (por ejemplo `.pdf`)
   usando LibreOffice con el script que ya está listo.

```
   Python  ─────────►  archivo fuente  ─────────►  LibreOffice  ─────────►  PDF / DOCX / etc.
 (lo crea)              (.docx/.html…)              (lo convierte)          (documento final)
```

> Los documentos finales **siempre** se guardan en: **`docs/generated_docs/`**

---

## ✅ Paso 0 — Instalar todo (una sola vez por computadora)

```bash
# 1) Instalar LibreOffice (detecta Mac / Linux / Windows automáticamente)
bash scripts/setup_libreoffice.sh

# 2) Instalar las librerías de Python del proyecto
pip install -r requirements.txt
```

Con esto quedan disponibles:
- **LibreOffice** → convierte entre formatos y a PDF.
- **python-docx** → crear Word (`.docx`).
- **python-pptx** → crear PowerPoint (`.pptx`).
- **openpyxl / pandas** → crear Excel (`.xlsx`) y CSV.

---

## 🔄 Convertir un archivo a otro formato (lo más común)

Ya sea que hayas creado el archivo con Python, con la mano, o que te lo pasaron,
para convertirlo usa **uno** de estos dos comandos (hacen lo mismo):

```bash
# Opción A: con Python
python scripts/generate_document.py <archivo_entrada> <formato_salida>

# Opción B: con bash
bash scripts/generate_document.sh <archivo_entrada> <formato_salida>
```

Ejemplos reales:

```bash
python scripts/generate_document.py reporte.html pdf     # HTML  -> PDF
python scripts/generate_document.py reporte.docx pdf     # Word  -> PDF
python scripts/generate_document.py slides.pptx  pdf     # PPTX  -> PDF
python scripts/generate_document.py datos.xlsx   csv     # Excel -> CSV
python scripts/generate_document.py datos.csv    xlsx    # CSV   -> Excel
```

Si no pones el formato de salida, por defecto es **pdf**.
El resultado aparece en **`docs/generated_docs/`**.

> ⚠️ **Regla de oro para no equivocarte:**
> LibreOffice **convierte todo muy bien a PDF**. Para *crear* Word, PowerPoint o
> Excel, **créalos directamente con Python** (ver la sección de abajo) — NO
> intentes convertir un HTML a `.docx` (eso no funciona, LibreOffice no tiene
> ese filtro). El script te avisará con un error claro si intentas una
> combinación inválida.
>
> | Quiero… | Haz esto |
> |---------|----------|
> | Un **PDF** | Crea un HTML (o usa un docx/pptx/xlsx) y conviértelo a `pdf` ✅ |
> | Un **Word** (`.docx`) | Créalo con `python-docx` ✅ |
> | Un **PowerPoint** (`.pptx`) | Créalo con `python-pptx` ✅ |
> | Un **Excel** (`.xlsx`) | Créalo con `pandas`/`openpyxl` ✅ |
> | Pasar un docx/pptx/xlsx **a PDF** | Conviértelo con el script a `pdf` ✅ |

### Formatos de salida disponibles

| Escribe… | Genera |
|----------|--------|
| `pdf`  | Documento PDF |
| `docx` | Word |
| `pptx` | PowerPoint |
| `xlsx` | Excel |
| `csv`  | CSV (desde una hoja de cálculo) |
| `html` | Página web |
| `odt` / `odp` / `ods` | Formatos abiertos de LibreOffice (texto / presentación / hoja) |
| `txt`  | Texto plano |

---

## 🐍 Cómo CREAR cada tipo de archivo con Python

Copia y pega estos ejemplos. Todos crean un archivo fuente que luego puedes
convertir con `generate_document.py` (por ejemplo a PDF).

### 1) Word (`.docx`) — con `python-docx`

```python
from docx import Document

doc = Document()
doc.add_heading("Reporte de Gastos Médicos", level=1)
doc.add_paragraph("Este es un párrafo de ejemplo.")
doc.add_heading("Hallazgos", level=2)
doc.add_paragraph("El tabaquismo es el factor más asociado a los cargos.")
doc.save("reporte.docx")
```

```bash
python scripts/generate_document.py reporte.docx pdf   # opcional: pasarlo a PDF
```

### 2) PowerPoint (`.pptx`) — con `python-pptx`

```python
from pptx import Presentation

prs = Presentation()
slide = prs.slides.add_slide(prs.slide_layouts[0])   # portada
slide.shapes.title.text = "Análisis de Gastos Médicos"
slide.placeholders[1].text = "Equipo 3 - TSCI 3"
prs.save("slides.pptx")
```

```bash
python scripts/generate_document.py slides.pptx pdf
```

### 3) Excel (`.xlsx`) — con `pandas` (lo más simple)

```python
import pandas as pd

df = pd.read_csv("data/insurance.csv")
df.describe().to_excel("estadisticas.xlsx")
```

```bash
python scripts/generate_document.py estadisticas.xlsx pdf
```

### 4) CSV — con `pandas`

```python
import pandas as pd

df = pd.read_csv("data/insurance.csv")
df_resumen = df.groupby("smoker")["charges"].mean().reset_index()
df_resumen.to_csv("resumen.csv", index=False)
```

### 5) HTML → PDF (la vía más flexible para reportes con formato)

```python
html = """
<h1>Reporte de Gastos Médicos</h1>
<p>Correlación de <b>charges</b> con ser fumador: <b>+0.79</b>.</p>
<table border="1" cellpadding="6">
  <tr><th>Grupo</th><th>Gasto medio</th></tr>
  <tr><td>Fumador</td><td>$32,050</td></tr>
  <tr><td>No fumador</td><td>$8,441</td></tr>
</table>
"""
with open("reporte.html", "w", encoding="utf-8") as f:
    f.write(html)
```

```bash
python scripts/generate_document.py reporte.html pdf
```

---

## 🤖 Si eres una IA, haz esto

1. Crea el archivo fuente con Python (usa uno de los ejemplos de arriba según
   el tipo de documento que te pidan: Word, PowerPoint, Excel, HTML…).
2. Convierte al formato final con:
   `python scripts/generate_document.py <archivo> <formato>`
3. El documento queda en `docs/generated_docs/`. Avísale al usuario la ruta.

---

## ❓ Problemas comunes

| Problema | Solución |
|----------|----------|
| `LibreOffice no está instalado` | Corre `bash scripts/setup_libreoffice.sh` |
| `No module named 'docx'` / `'pptx'` | Corre `pip install -r requirements.txt` |
| El PDF no respeta el diseño | Genera primero un **HTML** bien formateado y conviértelo a PDF |
| No encuentro el resultado | Siempre está en `docs/generated_docs/` |
| **Las tablas del HTML salen con columnas apretadas / texto partido letra por letra** | Es un fallo conocido de LibreOffice: si el `<body>` tiene `margin` en cm, calcula mal el ancho de las tablas. **Solución:** pon los márgenes con `@page { margin: 2.2cm; }` y deja `body { margin: 0; }`. Además, fija el ancho de columnas con el atributo HTML `width="26%"` en las celdas de la primera fila (no con CSS `style`, que LibreOffice ignora). |
| Una fórmula larga se desborda de su caja | Pon la etiqueta y la fórmula en líneas separadas con `<br>` y/o baja el `font-size` de la caja. |
