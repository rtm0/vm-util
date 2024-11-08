#!/bin/bash

INSERT_URL=http://localhost:8428/api/v1/import/prometheus
PERIOD=1

# TZ=UTC date --date=2024-10-09T00:00:00 +%s
TS_START=1728432000

# TZ=UTC date --date=2024-11-07T00:00:00 +%s
TS_END=1730937600

RESTART_START=$(TZ=UTC date --date=2024-10-25T18:00:00 +%s)
RESTART_END=$(TZ=UTC date --date=2024-10-25T22:00:00 +%s)

value=1
for (( ts=${TS_START}; ts < ${TS_END}; ts+=3600 ))
do
	value=$((value+1))

	if [[ $ts -lt $RESTART_START || $ts -gt $RESTART_END ]]
	then
		curl ${INSERT_URL} -d "metric{id=\"1\"} $value $ts"
		curl ${INSERT_URL} -d "metric{id=\"2\"} $value $ts"
	else
		echo skip
	fi
	
	
	echo $value $((TS_END-ts))
done
