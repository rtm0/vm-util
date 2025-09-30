#!/bin/bash

#!/bin/bash

INSERT_URL=http://localhost:8428/api/v1/import/prometheus
START=$(TZ=UTC date --date=2025-09-05T00:00:00 +%s)
END=$(TZ=UTC date --date=2025-09-10T00:00:00 +%s)

value=0
for ((secs = $START; secs <= $END; secs+=300))
do
	curl -d "metric01{label01=\"value01\"} $value ${secs}000" ${INSERT_URL}
	value=$((value + 1))
done
