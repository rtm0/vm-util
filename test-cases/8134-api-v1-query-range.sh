#!/bin/bash

set -x

URL=http://localhost:8428/api/v1/query_range

curl $URL -d "match[]={__name__=~\".*\"}" -d "query=metric_1" -d "step=24h" -d "start=2023-01-01T00:00:00Z" -d "end=2023-12-31T23:59:59Z" | jq .
curl $URL -d "match[]={__name__=~\".*\"}" -d "query=metric_1" -d "step=24h" -d "start=2024-01-01T00:00:00Z" -d "end=2024-01-31T23:59:59Z" | jq .
curl $URL -d "match[]={__name__=~\".*\"}" -d "query=metric_1" -d "step=24h" -d "start=2024-01-01T00:00:00Z" -d "end=2024-02-29T23:59:59Z" | jq .
curl $URL -d "match[]={__name__=~\".*\"}" -d "query=metric_1" -d "step=24h" -d "start=2024-01-01T00:00:00Z" -d "end=2024-12-31T23:59:59Z" | jq .

