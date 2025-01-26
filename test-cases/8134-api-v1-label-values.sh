#!/bin/bash

set -x

URL=http://localhost:8428/api/v1/label/month/values

curl $URL -d="match[]={__name__\"metric3\"}" -d "start=2023-01-01T00:00:00Z" -d "end=2023-12-31T23:59:59Z" | jq .
curl $URL -d="match[]={__name__\"metric3\"}" -d "start=2024-01-01T00:00:00Z" -d "end=2024-01-31T23:59:59Z" | jq .
curl $URL -d="match[]={__name__\"metric3\"}" -d "start=2024-01-01T00:00:00Z" -d "end=2024-02-29T23:59:59Z" | jq .
curl $URL -d="match[]={__name__\"metric3\"}" -d "start=2024-01-01T00:00:00Z" -d "end=2024-12-31T23:59:59Z" | jq .
