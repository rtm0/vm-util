#!/bin/bash

URL=http://localhost:8428/api/v1/admin/tsdb/delete_series

curl $URL -d 'match[]=metric1_april'
curl $URL -d 'match[]={__name__="metric2",may="true"}'
curl $URL -d 'match[]={__name__="metric3",month="june"}'
