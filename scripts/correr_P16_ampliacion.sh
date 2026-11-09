#!/bin/bash
# Problema #16 - Grupo A: AMPLIACION INCREMENTAL de la grilla 920x (agrega num_leaves 32 y 64).
# Usa los mismos numeros 9201-9204, asi cae en la misma carpeta WF<exp> y lee lo ya calculado.
# Uso:  bash correr_P16_ampliacion.sh 158227 423541 668141 732271 846061
# (Enrique: bash correr_P16_ampliacion.sh 172447 328577 397447 644839 845453)

NOTEBOOK="$HOME/buckets/b1/labo2026v/ExpColaborativos/z620_P16_ampliacion_920x.ipynb"
SALIDA="$HOME/buckets/b1/exp/P16_corridas"
EXP="$HOME/buckets/b1/exp"
VARIANTES="9201 9202 9203 9204"
mkdir -p "$SALIDA"

if [ $# -eq 0 ]; then echo "Falta la lista de semillas. Ej: bash correr_P16_ampliacion.sh 158227 423541"; exit 1; fi
command -v papermill >/dev/null || python3 -m pip install papermill

for semilla in "$@"; do
  for variante in $VARIANTES; do
    nombre="${variante}_s${semilla}"
    if [ -f "$SALIDA/${nombre}.amp_ok" ]; then echo "$(date '+%F %T')  $nombre ya ampliada, la salteo"; continue; fi
    if [ ! -f "$EXP/WF${nombre}/tb_grid_search_01.txt" ]; then echo "$(date '+%F %T')  OJO $nombre no tiene grilla previa, la salteo"; continue; fi
    rm -f "$EXP/WF${nombre}/sin_cambio.txt"
    echo "$(date '+%F %T')  INICIO  $nombre"
    if papermill "$NOTEBOOK" "$SALIDA/${nombre}_amp.ipynb" -k ir -p semilla "$semilla" -p variante "$variante"; then
      touch "$SALIDA/${nombre}.amp_ok"; echo "$(date '+%F %T')  CAMBIO  $nombre  (nuevo mejor: se reentreno y se subio a Kaggle)"
    elif [ -f "$EXP/WF${nombre}/sin_cambio.txt" ]; then
      touch "$SALIDA/${nombre}.amp_ok"; echo "$(date '+%F %T')  IGUAL   $nombre  (sin cambio, no se reentreno)"
    else
      echo "$(date '+%F %T')  FALLO   $nombre  (ver $SALIDA/${nombre}_amp.ipynb)"
    fi
  done
done
echo "$(date '+%F %T')  TERMINADO"
