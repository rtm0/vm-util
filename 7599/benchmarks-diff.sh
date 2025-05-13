#!/bin/bash

LHS_PREFIX=$1
RHS_PREFIX=$2
SCRIPTDIR=$(dirname $(realpath $0))

source ${SCRIPTDIR}/benchmarks.sh

function bm_diff() {
	local lhs_file=/tmp/${LHS_PREFIX}-$1
	local rhs_file=/tmp/${RHS_PREFIX}-$1
	benchstat ${lhs_file} ${rhs_file}
	echo
	echo
}

for b in "${BENCHMARKS[@]}"
do
    bm_diff $b
done
