#!/bin/bash

URL=http://localhost:8428/prometheus/api/v1/labels

START_0M="2024-12-31T00:00:00Z"
END_0M="2024-12-31T23:59:59.999Z"
curl $URL -d 'match[]={__name__=~".*"}' -d 'trace=1' -d "start=${START_0M}" -d "end=${END_0M}" | jq . > search-label-names-0m.json
echo
echo
START_10D="2025-01-01T00:00:00Z"
END_10D="2025-01-10T23:59:59.999Z"
curl $URL -d 'match[]={__name__=~".*"}' -d 'trace=1' -d "start=${START_10D}" -d "end=${END_10D}" | jq .  > search-label-names-10d.json
echo
echo
START_1M="2025-01-01T00:00:00Z"
END_1M="2025-01-31T23:59:59.999Z"
curl $URL -d 'match[]={__name__=~".*"}' -d 'trace=1' -d "start=${START_1M}" -d "end=${END_1M}" | jq .  > search-label-names-1m.json
echo
echo
START_2M="2025-01-01T00:00:00Z"
END_2M="2025-02-28T23:59:59.999Z"
curl $URL -d 'match[]={__name__=~".*"}' -d 'trace=1' -d "start=${START_2M}" -d "end=${END_2M}" | jq .  > search-label-names-2m.json
echo
echo
