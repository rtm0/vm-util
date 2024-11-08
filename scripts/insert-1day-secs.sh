#!/bin/bash

INSERT_URL=http://localhost:8428/api/v1/import/prometheus
PERIOD=1

# TZ=UTC date --date=2024-11-01T00:00:00 +%s
TS_START=1730419200
# TZ=UTC date --date=2024-11-02T00:00:00 +%s
TS_END=1730505600

for (( i=${TS_START}; i < ${TS_END}; i++ ))
do
	curl ${INSERT_URL} -d "metric01{id=\"$i\"} 1 $i"
	echo $((TS_END-i))
done
