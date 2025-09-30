#!/bin/bash

URL=http://localhost:8428/prometheus/api/v1/query

TIME_0M="2024-12-31T00:00:00Z"
curl $URL -d 'query={__name__=~".*"}' -d 'trace=1' -d "time=${TIME_0M}" | jq . > query-0m.json
echo
echo
TIME_10D="2025-01-01T00:00:00Z"
curl $URL -d 'query={__name__=~".*"}' -d 'trace=1' -d "time=${TIME_10D}" | jq . > query-10d.json
echo
echo
