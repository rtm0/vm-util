#!/bin/bash

URL=http://localhost:8428/api/v1/import/prometheus
BEGIN_SECS=$(TZ=UTC date --date=2025-01-01T00:00:00 +%s)
LIMIT_SECS=$(TZ=UTC date --date=2025-05-01T00:00:00 +%s)

for ((ts=$BEGIN_SECS; ts < $LIMIT_SECS; ts+=86400 ))
do
	curl $URL -d "metric1{label11=\"value11-1\"} 111 $ts"
	curl $URL -d "metric1{label11=\"value11-2\"} 112 $ts"
	curl $URL -d "metric1{label11=\"value11-3\"} 113 $ts"
	curl $URL -d "metric1{label11=\"value11-4\"} 114 $ts"
	curl $URL -d "metric1{label12=\"value12-1\"} 121 $ts"
	curl $URL -d "metric1{label13=\"value13-1\"} 131 $ts"
	curl $URL -d "metric1{label14=\"value14-1\"} 141 $ts"
	curl $URL -d "metric2{label21=\"value21-1\"} 211 $ts"
	curl $URL -d "metric3{label31=\"value31-1\"} 311 $ts"
	curl $URL -d "metric4{label41=\"value41-1\"} 411 $ts"
done
