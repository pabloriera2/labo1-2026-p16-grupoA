
# Operación Campo Clave · Problema #16 · Grupo A

**Laboratorio de Implementación I** · Maestría en Ciencia de Datos con IA · Universidad Austral · 2026
**Grupo A:** Pablo Riera · Enrique Gonzalvo

🎬 **Video:** https://youtu.be/ofhLwPeGtm0

---

## Pregunta

¿Conviene que LightGBM use los **campos clave** `numero_de_cliente` y `foto_mes` como variables predictoras, o es mejor anularlos?
Medimos su efecto sobre la **ganancia** en `future = 202109` (Kaggle, competencia Analista Jr).

## Hipótesis

- **numero_de_cliente:** H0 = quitarlo no cambia la ganancia. Creemos que funciona como un *proxy* de la antigüedad del cliente (correlación −0,74 con `cliente_antiguedad` en un análisis previo con canaritos) y que, sin él, el modelo usará `cliente_antiguedad` en su lugar.
- **foto_mes:** H0 = quitarlo no cambia la ganancia. El mes a predecir (202109) queda fuera del rango de entrenamiento, así que los cortes del árbol por `foto_mes` no deberían generalizar.

Se rechaza H0 si el test de Wilcoxon pareado da p < 0,05.

## Diseño experimental

| | |
|---|---|
| **Workflow** | z620 (Analista Jr), sin cambios en preprocesamiento ni Feature Engineering |
| **Entrenamiento** | 201901–202105 · validación 202107 · entrenamiento final 201901–202107 · future 202109 |
| **Variantes** | V1 Base · V2 Sin ID · V3 Sin Mes · V4 Sin Ambos (se quitan de `campos_buenos`; siguen en el dataset) |
| **Semillas** | 10 por variante (5 de cada integrante), las mismas en las 4 variantes |
| **Optimización** | grid search por AUC en 202107 en **cada** corrida, con corrección `modifyList()` en `param_final` |
| **Grilla (920x)** | `num_leaves` 128…2048 × `min_data_in_leaf` 64…8192, `feature_fraction` 0,5 |
| **Métrica** | máximo del Public de Kaggle entre 7 cortes (2000 a 2600 envíos) por corrida |
| **Comparación** | `pairwise.wilcox.test` pareado por semilla, con corrección de Holm |

Total: 4 variantes × 10 semillas = **40 corridas por tanda**, 280 subidas a Kaggle por tanda.

## Resultados (tanda 920x)

| Variante | Ganancia vs. Base | p (Wilcoxon) |
|---|---|---|
| Base | 86,11 (referencia) | — |
| Sin ID | −0,1 % | 0,85 |
| Sin Mes | +1,0 % | 0,63 |
| Sin Ambos | +0,3 % | 0,85 |

Con corrección de Holm, todos p = 1. La tanda anterior (919x) dio lo mismo (p entre 0,49 y 0,92).
**No se rechaza H0 en ninguna variante.**

### Sensibilidad a la grilla
- En la 920x, `num_leaves = 128` (borde de la grilla) apareció en 10 de 40 corridas.
- Diagnóstico con 32 y 64 hojas (Base y Sin ID, 3 semillas): 32 hojas nunca dio la mejor AUC y en 5 de 6 casos la mejor siguió en 128–256 hojas → el óptimo está **dentro** de la grilla.

### Importancia de variables
| Variable (920x, 5 semillas) | Puesto en Base | Gain en Base | Gain en Sin ID |
|---|---|---|---|
| foto_mes | 6–8 | 2,6 % | 2,4 % |
| numero_de_cliente | 49–55 | 0,33 % | — (excluida) |
| cliente_antiguedad | 58–77 | 0,28 % | 0,23 % |

## Conclusiones

- Con este modelo y 10 semillas **no hay evidencia** de que quitar `numero_de_cliente`, `foto_mes` o ambos cambie la ganancia en 202109.
- **El ID no es "la llave secreta":** aporta el 0,33 % del gain. Y no se confirmó nuestra hipótesis de que `cliente_antiguedad` ocuparía su lugar.
- **foto_mes engaña:** el modelo lo usa mucho (top 10), pero no ayuda a predecir un mes futuro, porque los árboles no extrapolan.

## Limitaciones

- El Public es solo el 30 % de 202109 y tiene mucho ruido.
- Con 10 semillas solo se detectan efectos de alrededor de ±4 %: no rechazar H0 **no** prueba que las variantes sean iguales.
- El resultado vale para un solo mes (202109).
- En el análisis previo de canaritos, un error de tipeo en la semilla (`semila_primigenia`) hizo que esa corrida no fuera reproducible. El LightGBM sí usó la semilla correcta.

## Contenido del repositorio

```
notebooks/
  z620_P16_loop.ipynb              plantilla parametrizada (papermill): variante + semilla
  z620_P16_loop_919x.ipynb         tanda 919x (grilla num_leaves 256–2048, min_data 128–4096)
  z620_P16_loop_920x.ipynb         tanda 920x (grilla num_leaves 128–2048, min_data 64–8192)  ← resultado principal
  z620_P16_diag_922x.ipynb         diagnóstico de borde: 32 y 64 hojas (Base y Sin ID, 3 semillas)
  z620_P16_ampliacion_920x.ipynb   ampliación incremental de la grilla sobre la 920x
  z620_P16_9161_base.ipynb         corrida base de referencia
scripts/
  correr_P16.sh                    loop de 4 variantes × semillas con papermill
  correr_P16_919x.sh  correr_P16_920x.sh  correr_P16_diag.sh  correr_P16_ampliacion.sh
corridas/
  NNNV_sSEMILLA.ipynb              notebook ejecutado de cada corrida
                                   NNN = tanda (917–922), V = variante (1 Base, 2 Sin ID, 3 Sin Mes, 4 Sin Ambos)
resultados/
  impo_P16.txt                     importancia de variables (gain) por variante y semilla
  mejores_hp_P16.txt               hiperparámetros elegidos en cada corrida
logs/
  loop_P16_*.log                   logs de ejecución de las tandas
```

Las tandas 917x y 918x fueron pruebas iniciales del pipeline; los resultados reportados son de la **920x** (y la 919x como confirmación).
Las semillas de Pablo son 158227, 423541, 668141, 732271 y 846061; las de Enrique, 172447, 328577, 397447, 644839 y 845453.

## Cómo reproducir

En la VM de la cátedra (desktop-jr), con el dataset `analistajr_competencia_2026` y Kaggle CLI configurado:

```bash
cd ~/buckets/b1/labo2026v/ExpColaborativos
nohup bash correr_P16_920x.sh > loop_P16_920x.log 2>&1 &   # ver al inicio del script las semillas y variantes
```

Cada corrida ejecuta la plantilla con papermill para una variante y una semilla: grid search por AUC en 202107, entrenamiento final 201901–202107, predicción de 202109 y 7 submits a Kaggle (cortes de 2000 a 2600 envíos). Cada tanda completa (4 variantes × 5 semillas) tarda unas 28 horas.
Límite de Kaggle: 100 submits por día, se resetean a las 21:00 (hora argentina).

El dataset no se incluye en el repositorio.
