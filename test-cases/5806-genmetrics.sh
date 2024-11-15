#!/bin/bash

mkdir -p /tmp/5806
PROM_FILE=/tmp/5806/repro_metrics.prom

USERS=('goku' 'gohan' 'goten' 'chichi' 'tien' 'yamcha' 'buu' 'krillin' 'dende' 'android18' 'cell')
PRIORITIES=('1005500000' '905000000' '1001100000' '907000010')

gen_metric () {
  USER=$1
  PRI=$2
  MEM=$3

  METRIC="repro_test_memory_at_priority{priority=\"$PRI\",user=\"$USER\"} $MEM"

  echo $METRIC
}

while true; do

  echo "# HELP repro_test_memory_at_priority demo repro metric for NaN in Victoriametrics" >> $PROM_PATH/$PROM_FILE.tmp
  echo "# TYPE repro_test_memory_at_priority gauge" > $PROM_PATH/$PROM_FILE.tmp

  for USER in ${USERS[@]}; do
    # how many priorities for this user this iter
    RANDCHOICE=$((0 + $RANDOM % ${#PRIORITIES[@]}))

    for (( i=0 ; i <= $RANDCHOICE ; i++ )); do
      RANDMEM=$((10240 + $RANDOM % 1024000))
      gen_metric $USER ${PRIORITIES[i]} $RANDMEM >> $PROM_FILE.tmp
    done

  done

  mv $PROM_FILE.tmp $PROM_FILE
  sleep 10
done;
