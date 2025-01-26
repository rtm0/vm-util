#!/bin/bash

URL=http://localhost:8428/api/v1/import/prometheus
BEGIN_SECS=$(TZ=UTC date --date=2024-01-01T00:00:00 +%s)
LIMIT_SECS=$(TZ=UTC date --date=2025-01-01T00:00:00 +%s)
VALUE=0
for ((ts=$BEGIN_SECS; ts < $LIMIT_SECS; ts+=3600 ))
do
	
	month="$(LC_ALL=C TZ=UTC date --date=@$ts +%B)"
	month="${month,,}"

	curl $URL -d "metric1_$month $VALUE $ts"
	curl $URL -d "metric2{$month=\"true\"} $VALUE $ts"
	curl $URL -d "metric3{month=\"$month\"} $VALUE $ts"

	VALUE=$((VALUE+1))
done
