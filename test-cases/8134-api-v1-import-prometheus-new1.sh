#!/bin/bash

URL=http://localhost:8428/api/v1/import/prometheus
BEGIN_SECS=$(TZ=UTC date --date=2025-03-01T00:00:00 +%s)
LIMIT_SECS=$(TZ=UTC date --date=2025-04-01T00:00:00 +%s)

for ((ts=$BEGIN_SECS; ts < $LIMIT_SECS; ts+=3600 ))
do
	curl $URL -d "new_metric1{new_label1=\"new_value1\"} 200 $ts"
done
