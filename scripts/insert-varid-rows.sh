#!/bin/bash

INSERT_URL=http://localhost:8428/api/v1/import/prometheus
PERIOD=1

while true
do
	curl -d 'metric01{label01="value01"} 100' -X POST ${INSERT_URL}; sleep ${PERIOD};
done
