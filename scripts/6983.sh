#!/bin/bash

INSERT_URL=http://localhost:8428/api/v1/import/prometheus
TS=$(date --date=2024-10-31T07:59:00 +%s)

for (( i = 1; i <= 2; i++ ))
do
	curl ${INSERT_URL} -d "metric1 $i $((TS - i*60))"
	curl ${INSERT_URL} -d "metric2 $i $((TS - i*60+1))"
done
