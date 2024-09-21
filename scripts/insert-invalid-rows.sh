#!/bin/bash

INSERT_URL=http://localhost:8428/api/v1/import/prometheus
TOO_OLD_SECS=`TZ=UTC date --date=2000-01-01 +%s`
TOO_NEW_SECS=`TZ=UTC date --date=2030-01-01 +%s`
PERIOD=0.1

while true
do
	# curl ${INSERT_URL} -d "metric01{label01=\"value01\"} NaN"
	# curl ${INSERT_URL} -d "metric01{label01=\"value01\"} 100 ${TOO_OLD_SECS}"
	# curl ${INSERT_URL} -d "metric02{label02=\"value02\"} 100 ${TOO_NEW_SECS}"
	# sleep ${PERIOD}
done
