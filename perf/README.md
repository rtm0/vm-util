# Performance Testing

## Config 01

Want:

- 8.3M*4 = 33.3M active timeseries
- 153K*4 = 611K ingestion rate
- 25M*4 = 100M/day churn rate
- 289*4 = 1.16K/s churn rate

Cluster:

- 4 vmstorage replicas, 4 cpu, 8Gi mem

Benchmark:

- 813 metrics per host
- 33.3M / 813 = 41000 hosts
- 1m scrape interval
- 2% churn rate every 10m



## How-to

### Create a secret with license:

```shell
k create secret generic vm-license --from-file=license=/home/user/vm-license
```

### Open VMUI

VMUI for cluster deployment: http://localhost:8481/select/0/vmui/
See: https://docs.victoriametrics.com/victoriametrics/cluster-victoriametrics/#url-format

### Count number of series per instance

seriesPerHost:

```
count({instance="host-0"})
```

```
activeSeries == hosts * seriesPerHost
ingestionRate == activeSeries / scrapeInterval
```
