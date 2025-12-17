# Load Testing

## Objective

Test the functionality of VictoriaMetics in an environment close to a typical
prod.

## Load Calculations

Use [loadcalc.go](loadcalc.go). For example:

```shell
go run loadcalc.go -seriesPerTarget=1000 --targetsCount=10000 -scrapeInterval=10s -scrapeConfigUpdatePercent=1 -scrapeConfigUpdateInterval=1m
Ingestion rate 1000000
Churn rate 1s 1666
Churn rate 1h 6000000
Churn rate 24h 144000000
Active time series (initial) 10000000
Active time series (effective) 16000000
```

One scrape target exports roughly 1000 metrics. So use this number when
calculating the load. Once the load is applied to the system under test, compare
the expexted values with the actual onces. Adjust if necessary:

-   by changing the target count or
-   by finding the actual number of metrics per target (see below).

### How to find number of time series per targer:

The number of metrics exported by a target varies depending on environment. It
is best to [set up](#set-up) some loadtest with default values and then find
that number using the instructions below.

-   Make `vmselect` available locally

    ```shell
    k port-forward svc/vmselect-${LOADTEST_NAME} 8481
    ```

-   Access the `VMUI`: http://localhost:8481/select/0/vmui/#
-   Navigate to `Explore > Explore Cardinality` page
-   Enter `{instance="host-0", revision="r0"}` into the `Time series selector`
-   Hit `Enter`
-   The `Total series` counter will show how many unique time series exports
    that given instance.
-   Try changing the instance to some other host. The counter will be more or
    less the same.

## Set Up

1.  Create a private cluster:

    ```shell
    vm-cluster-create
    ```

    Set up Cloud NAT: https://cloud.google.com/nat/docs/gke-example#create-nat


2.  Download and install the
    [VictoriaMetrics K8s Stack](https://docs.victoriametrics.com/helm/victoria-metrics-k8s-stack/)
	Helm chart:

    Download:

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

3.  Create a deployment under test

    Create a namespace for the load test (or just use default). The name of the
    namespace is also used as the deployment name and corresponds to a subdir in
    this dir.

    ```shell
    k create ns ${LOADTEST_NAME}
    ```

    If you plan to deploy enterprise binaries, create a secret with the license:

    ```shell
    k -n ${LOADTEST_NAME} create secret generic vm-license --from-file=license=/home/user/vm-license
    ```

    Create the deployment under test (choose one command out of four below):

    ```shell
    k -n ${LOADTEST_NAME} apply -f ${LOADTEST_NAME}/vmsingle-oss.yaml
    k -n ${LOADTEST_NAME} apply -f ${LOADTEST_NAME}/vmsingle-ent.yaml
    k -n ${LOADTEST_NAME} apply -f ${LOADTEST_NAME}/vmcluster-oss.yaml
    k -n ${LOADTEST_NAME} apply -f ${LOADTEST_NAME}/vmcluster-ent.yaml
    ```

4.  Install the [benchmark](https://github.com/VictoriaMetrics/prometheus-benchmark)

    Choose the command depending on the deployment type from the previous step:

    ```shell
    helm install ${LOADTEST_NAME} -n ${LOADTEST_NAME} -f ${LOADTEST_NAME}/benchmark-vmsingle.yaml \
      /home/user/p/github.com/VictoriaMetrics/prometheus-benchmark/chart
    helm install ${LOADTEST_NAME} -n ${LOADTEST_NAME} -f ${LOADTEST_NAME}/benchmark-vmcluster.yaml \
      /home/user/p/github.com/VictoriaMetrics/prometheus-benchmark/chart
    ```

## Tear Down

1.  Uninstall the benchmark

    ```shell
    helm uninstall ${LOADTEST_NAME} -n ${LOADTEST_NAME}
    ```

2.  Delete cluster under test

	Choose the command depending on the deployment type:

    ```shell
    k delete -f ${LOADTEST_NAME}/vmsingle-oss.yaml
    k delete -f ${LOADTEST_NAME}/vmsingle-ent.yaml
    k delete -f ${LOADTEST_NAME}/vmcluster-oss.yaml
    k delete -f ${LOADTEST_NAME}/vmcluster-ent.yaml

    k -n ${LOADTEST_NAME} delete pvc --all
    ```

3.  Uninstall `VictoriaMetrics K8s Stack`

    ```shell
    helm uninstall vmks -n vmks
    ```

4.  Delete cluster

    ```shell
    vm-cluster-list
    vm-cluster delete ${CLUSTER_NAME}
    ```
