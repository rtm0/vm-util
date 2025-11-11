# Partition Index Load Testing

## Objective

## Results

## Steps to Reproduce

Create a private cluster:

```shell
vm-cluster-create
```

Set up Cloud NAT: https://cloud.google.com/nat/docs/gke-example#create-nat


Download [VictoriaMetrics K8s Stack](https://docs.victoriametrics.com/helm/victoria-metrics-k8s-stack/) Helm chart:

```shell
helm repo add vm https://victoriametrics.github.io/helm-charts/
helm repo update
helm search repo vm/victoria-metrics-k8s-stack -l
```

Create a separate namespace for the k8s stack:

```shell
k create ns vmks
```

Install the chart:

```shell
helm install vmks vm/victoria-metrics-k8s-stack -n vmks \
  --set 'defaultDashboards.dashboards.victoriametrics-cluster.enabled=true'
```

Get Grafana admin password:

```shell
k -n vmks get secret vmks-grafana -o jsonpath='{.data}'; echo
```

Make Grafana avaiable locally:

```shell
k -n vmks port-forward svc/vmks-grafana 3000:80
```

Navigate [Grafana](http://localhost:3000/) and ensure that
`VictoriaMetrics - cluster` dashboard is present.

Create a namespace for the load test:

```shell
k create ns loadtest
```

Create a secret with the license:

```shell
k -n loadtest create secret generic vm-license --from-file=license=/home/user/vm-license
```

Create a vmcluster under test:

```shell
k -n loadtest apply -f enterprise-cluster.yaml
```

Create benchmark namespace:

```shell
k create ns benchmark
```

Install the benchmark:

```shell
helm install loadtest -n benchmark -f benchmark.yaml \
  /home/user/p/github.com/VictoriaMetrics/prometheus-benchmark/chart
```

### Cleanup

Uninstall benchmark:

```shell
helm uninstall loadtest -n benchmark
```

Delete cluster under test:

```shell
k -n loadtest delete -f enterprise-cluster.yaml
k -n loadtest delete pvc --all
```

Uninstall k8s stack:

```shell
helm uninstall vmks -n vmks
```

Delete cluster:

```
vm-cluster-list
vm-cluster delete ...
```
