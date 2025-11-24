# Load Testing

## Objective

Test the functionality of VictoriaMetics in an environment close to a typical
prod.

## Load Calculations

TODO

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

    ```
    vm-cluster-list
    vm-cluster delete ${CLUSTER_NAME}
    ```
