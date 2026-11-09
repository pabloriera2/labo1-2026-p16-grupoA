#!/bin/bash
# Problema #16 - Grupo A: corre las 4 variantes para cada semilla, una tras otra.
# Uso:  bash correr_P16.sh 158227 423541 668141 732271 846061
# (Enrique: bash correr_P16.sh 172447 328577 397447 644839 845453)

NOTEBOOK="$HOME/buckets/b1/labo2026v/ExpColaborativos/z620_P16_loop.ipynb"
SALIDA="$HOME/buckets/b1/exp/P16_corridas"
VARIANTES="9181 9182 9183 9184"
mkdir -p "$SALIDA"

if [ $# -eq 0 ]; then echo "Falta la lista de semillas. Ej: bash correr_P16.sh 158227 423541"; exit 1; fi
command -v papermill >/dev/null || pip install --user papermill
export PATH="$HOME/.local/bin:$PATH"

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
