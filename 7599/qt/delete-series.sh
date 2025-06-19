#!/bin/bash

URL=http://localhost:8428/api/v1/admin/tsdb/delete_series

curl $URL -d 'match[]={__name__=~".*"}' -d 'trace=1' | jq . > delete-series.json
