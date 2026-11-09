#!/bin/bash
# Problema #16 - Grupo A: DIAGNOSTICO 922x, solo grid search (Base y Sin ID), sin Kaggle.
# Uso:  bash correr_P16_diag.sh 158227 423541 668141
# (no hace falta que Enrique lo corra)

NOTEBOOK="$HOME/buckets/b1/labo2026v/ExpColaborativos/z620_P16_diag_922x.ipynb"
SALIDA="$HOME/buckets/b1/exp/P16_corridas"
VARIANTES="9221 9222"
mkdir -p "$SALIDA"

if [ $# -eq 0 ]; then echo "Falta la lista de semillas. Ej: bash correr_P16_diag.sh 158227 423541"; exit 1; fi
command -v papermill >/dev/null || python3 -m pip install papermill
command -v papermill >/dev/null || { echo "No se pudo instalar papermill"; exit 1; }

for semilla in "$@"; do
  for variante in $VARIANTES; do
    nombre="${variante}_s${semilla}"
    if [ -f "$SALIDA/${nombre}.ok" ]; then echo "$(date '+%F %T')  $nombre ya estaba hecha, la salteo"; continue; fi
    echo "$(date '+%F %T')  INICIO  $nombre"
    if papermill "$NOTEBOOK" "$SALIDA/${nombre}.ipynb" -k ir -p semilla "$semilla" -p variante "$variante"; then
      touch "$SALIDA/${nombre}.ok"
      echo "$(date '+%F %T')  OK      $nombre"
    else
      echo "$(date '+%F %T')  FALLO   $nombre  (ver $SALIDA/${nombre}.ipynb)"
    fi
  done
done
echo "$(date '+%F %T')  TERMINADO"
