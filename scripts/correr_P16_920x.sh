#!/bin/bash
# Problema #16 - Grupo A: corre las 4 variantes para cada semilla, una tras otra.
# Uso:  bash correr_P16_920x.sh 158227 423541 668141 732271 846061
# (Enrique: bash correr_P16_920x.sh 172447 328577 397447 644839 845453)

NOTEBOOK="$HOME/buckets/b1/labo2026v/ExpColaborativos/z620_P16_loop_920x.ipynb"
SALIDA="$HOME/buckets/b1/exp/P16_corridas"
VARIANTES="9201 9202 9203 9204"
mkdir -p "$SALIDA"

if [ $# -eq 0 ]; then echo "Falta la lista de semillas. Ej: bash correr_P16_920x.sh 158227 423541"; exit 1; fi
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
