#!/bin/bash

END=$(TZ=UTC date +%s)
START=$(($END-5*60))
NUM_METRICS=5000000

while true
do
	ID=$(($SRANDOM%${NUM_METRICS}))
	curl http://localhost:8428/prometheus/api/v1/query_range \
       -d "query=metric${ID}" \
       -d "start=${START}" \
       -d "end=${END}" \
       -d "step=5s"
	echo
done
