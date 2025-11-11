# Performance Testing

## Config 01

Create a private cluster:

```shell
vm-cluster-create
```

Set up Cloud NAT: https://cloud.google.com/nat/docs/gke-example#create-nat

Install [VictoriaMetrics K8s Stack](https://docs.victoriametrics.com/helm/victoria-metrics-k8s-stack/):

```shell
helm repo add vm https://victoriametrics.github.io/helm-charts/
helm repo update
helm search repo vm/victoria-metrics-k8s-stack -l


helm install vmks vm/victoria-metrics-k8s-stack \
  --set vmsingle.enabled=false
```


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
