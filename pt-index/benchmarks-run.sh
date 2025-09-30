#!/bin/bash

PREFIX=$1
SCRIPTDIR=$(dirname $(realpath $0))

source ${SCRIPTDIR}/benchmarks.sh

function bm_run() {
  local name=$1
  local outfile=/tmp/${PREFIX}-${name}
  GOEXPERIMENT=synctest go test ./lib/storage -run=NONE \
	-bench="^${name}$" -count=10 -timeout=20m \
	-cpuprofile ${outfile}.cpuprofile \
	--loggerLevel=ERROR \
    | tee ${outfile}

  echo
  echo ${outfile}
  echo
}

for b in "${BENCHMARKS[@]}"
do
    bm_run $b
done
