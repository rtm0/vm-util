#!/bin/bash

URL=http://localhost:8428/api/v1/import/prometheus
BEGIN_SECS=$(TZ=UTC date --date=2025-02-01T00:00:00 +%s)
LIMIT_SECS=$(TZ=UTC date --date=2025-03-01T00:00:00 +%s)

for ((ts=$BEGIN_SECS; ts < $LIMIT_SECS; ts+=3600 ))
do
	curl $URL -d "legacy_metric1{legacy_label1=\"legacy_value1\"} 100 $ts"
done
