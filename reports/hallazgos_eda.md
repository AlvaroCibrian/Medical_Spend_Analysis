# Hallazgos del Análisis Exploratorio de Datos (EDA)

> Interpretación de los resultados del EDA (`notebooks/01_eda.ipynb`). Este texto es
> material de apoyo para redactar la sección de resultados del documento final; por eso
> se mantiene fuera del notebook, que solo describe qué hace cada bloque de código.

## 1. Detección de outliers

- **`bmi`**: presenta unos pocos outliers en el extremo alto (personas con obesidad
  severa). Son valores plausibles clínicamente.
- **`charges`**: presenta un número considerable de outliers hacia arriba, asegurados
  con cargos muy elevados (típicamente fumadores y/o con condiciones costosas).

**Decisión:** se **conservan** todos los outliers. En este dataset no son errores de
captura, sino **casos reales** (personas con BMI alto o con gastos médicos altos que
existen de verdad). Eliminarlos distorsionaría el análisis de riesgo, que justamente
busca caracterizar esos perfiles costosos.

## 2. Distribución de variables numéricas

(El valor `skew` mide la asimetría; ~0 = simétrica.)

- **`age`**: distribución bastante uniforme/plana (skew ≈ 0.05), con un pico en los más
  jóvenes (18–19 años). No es normal, pero es simétrica.
- **`bmi`**: aproximadamente normal (skew ≈ 0.28), en forma de campana centrada cerca de 30.
- **`children`**: variable discreta; la mayoría tiene 0 hijos y decrece hacia 5.
- **`charges`**: claramente **sesgada a la derecha** (skew ≈ 1.52): la mayoría paga
  cargos bajos y una minoría paga cargos muy altos. Sugiere que para modelar `charges`
  podría convenir una transformación logarítmica.

## 3. Distribución de variables categóricas

- **`sex`**: prácticamente balanceado (≈ 50/50 entre male y female).
- **`smoker`**: fuertemente desbalanceado: ~1063 no fumadores vs ~274 fumadores
  (≈ 20% fuma). Importante al interpretar el efecto del tabaquismo.
- **`region`**: repartida de forma bastante pareja entre las 4 regiones, con *southeast*
  ligeramente por encima.

## 4. Relación entre variables clave (hallazgo central)

- **`age` vs `charges`**: se ven bandas ascendentes: los cargos suben con la edad, pero
  los fumadores forman una banda claramente por encima de los no fumadores a cualquier edad.
- **`bmi` vs `charges`**: el efecto es más marcado aún: entre los fumadores, un `bmi`
  alto dispara los cargos. Entre no fumadores el `bmi` casi no eleva los cargos.
- **Conclusión visual:** `smoker` es el separador más fuerte de los cargos, y su efecto
  se potencia cuando se combina con un `bmi` alto.

## 5. Complementos

### 5.1 `charges` en escala logarítmica

Al aplicar `log`, el sesgo de `charges` se reduce drásticamente (de skew ≈ 1.52 a ≈ −0.09)
y la distribución se acerca a una normal. Recomendación: considerar modelar
`log(charges)` en lugar de `charges` directo.

### 5.2 `charges` por grupo

- **`smoker`**: diferencia enorme; los fumadores pagan en promedio ~4x lo que un no
  fumador. Es el factor dominante.
- **`sex`**: diferencia pequeña (los hombres pagan un poco más en promedio, por su cola
  de valores altos).
- **`region`**: diferencias menores entre regiones; *southeast* algo más alta.

## Resumen de hallazgos

1. **Outliers:** existen en `bmi` y sobre todo en `charges`; se conservan por ser casos
   reales, no errores.
2. **Distribuciones:** `age` plana, `bmi` casi normal, `children` discreta con mayoría en
   0, y `charges` fuertemente sesgada a la derecha (se sugiere `log`).
3. **Categóricas:** `sex` balanceado, `region` pareja, `smoker` desbalanceado (~20%).
4. **Relaciones:** ser fumador es el separador más fuerte de los cargos, y su efecto se
   amplifica con un `bmi` alto.
