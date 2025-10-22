# Partition Index Performace Testing

## Preconditions

### Types of Benchmarks

We will perform three types of benchmarks:

1. [Data Ingestion](#data-ingestion): these benchmarks examine the performance
   of data ingestion in context of the use cases that we believe will be
   applicable to most of the users.
2. [Index Queries](#index-queries): these benchmarks examine the performace of
   the retrieval of various index data, such as metric names, label names, and
   label values. Basic data retrieval is also covered by these benchmarks.
   Again, we will cover the most common use cases only.
3. [Data Queries](#data-queries): examines the performance of some selected
   Prom/MetricsQL queries. It is unlikely that these queries are the most used
   ones, but they are designed to examine different constructs of the query
   language to see how they affect performance of data retrieval.

### Versions under Test

All benchmarks will be comparing `OSS vmsingle v1.127.0` and
`OSS vmsingle w/ pt-index` (which is basically the current `master` + `pt-index`
changes).

### Testing Environment

All benchmarks are run on
[e2-standard-8](https://cloud.google.com/compute/docs/general-purpose-machines#e2_machine_types)
GCP instance because:

- Running on a benchmark personal laptop is not reliable because it typically
  has bunch of other stuff running and it will be hard for others to reproduce.
- This is the default type of node in GCP GKE and therefore will be chosen more
  often.
- Previous benchmark runs show that VictoriaMetrics performance is the worst on
  this type of instance. Other instance types typically show much better
  results, such as
  [n2-standard-8](https://cloud.google.com/compute/docs/general-purpose-machines#n2_series)
  and
  [n2d-standard8](https://cloud.google.com/compute/docs/general-purpose-machines#n2d_machines).
  And it is important to show the worst case scenario.
  - The `worst performance` here means that whenever we add a feature that may
    affect the performace of the storage, the performance of the new version
	compared to the old version is the worst on `e2`, while benchmarks run on
	`n2` or `n2d` show often acceptable or even excellent results. I.e. we are
	not comparing the performance of a given version on `e2` and `n2` which will
	obviously be different.

## Data Ingestion

To test data ingestion we will be using [TSBS](https://github.com/timescale/tsbs).

We will consider the following use cases:

1. [Empty](#empty): Load the data into an empty database. This benchmark
   compares the performance of new `pt-index` deployments with `v1.127.0`
   deployments that haven't been upgraded to `pt-index` yet. This benchmark
   should answer the question whether the `pt-index` is better or worse than
   previous versions in context of data ingestion.
2. [Non-empty with Restart](#non-empty-with-restart): Load the data into a
   non-empty database after the database restart. This benchmark symulates the
   upgrade of existing deployments from `v1.127.0` to `pt-index`. It should
   answer the question if there will be any performance degradation shortly
   after upgrading the deployment to `pt-index`.

For each use case we will use the same data:

- The time range is the whole previous day
- There are 100K instances. Each instance emits 10 unique metrics (TSBS
  [cpu-only](https://github.com/timescale/tsbs?tab=readme-ov-file#dev-ops) use
  case). Therefore, 100K instances emit 1M unique metrics.
- Samples are emitted every 80s and there are 3600*24 / 80 = ~1K
  80s intervals within 24 hours
- And total number of samples: 1M metrics × ~1K intervals = ~1B

The data is generated only once before all tests:

```shell
make tsbs-build tsbs-generate-data
```

During each test, 4 concurrent workers ingest the data.

Below are the benchmark results and the description how each benchmark for done.

### Empty

Overall the `pt-index` performance is very close to `v1.127.0`.

Load summary:

- `v1.127.0`: loaded 1080000000 metrics in 610.252sec with 4 workers (mean rate 1769761.57 metrics/sec)
- `pt-index`: loaded 1080000000 metrics in 605.958sec with 4 workers (mean rate 1782301.27 metrics/sec)

I.e. pt-index is `~1%` faster.

Below is the graph of the sample load rate over time:

![samples/sec](../perf/data-ingestion-empty-v1.127.0-pt-index.png)

Comparison of some important metrics:

Metric                             | v1.127.0    | pt-index    | diff %
---------------------------------- | ----------- | ----------- | ------
process_cpu_seconds_system_total   | 218.84      | 193.63      | -11.52
process_cpu_seconds_total          | 3722.71     | 3663.73     | 1.58
process_cpu_seconds_user_total     | 3503.87     | 3470.1      | -1.02
process_resident_memory_bytes      | 1579757568  | 1634140160  | 3.44
process_resident_memory_peak_bytes | 2818256896  | 2770223104  | -1.7
process_io_read_bytes_total        | 42186355770 | 42023530052 | -0.38
process_io_written_bytes_total     | 5540444607  | 5449190023  | 1.65

Raw load logs:

- [v1.127.0](../perf/data-ingestion-empty-v1.127.0.log)
- [pt-index](../perf/data-ingestion-empty-pt-index.log)

#### How to Run

In terminal #2, start `v1.127.0`:

```shell
git checkout v1.127.0
make clean victoria-metrics
rm -Rf ../data/*
./bin/victoria-metrics -storageDataPath=../data
```

In terminal #1, run TSBS data load:

```shell
make tsbs-load-data | tee data-ingestion-empty-v1.127.0.log
```

Stop `v1.127.0`.

In terminal #3, start `pt-index`:

```shell
git switch issue-7599
make clean victoria-metrics
rm -Rf ../data/*
./bin/victoria-metrics -storageDataPath=../data
```

In terminal #1, run TSBS data load:

```shell
make tsbs-load-data | tee data-ingestion-empty-pt-index.log
```

Stop `pt-index`.

In terminal #1, plot load graph:

```shell
make tsbs-plot-load \
  TSBS_LOAD_RESULT_CSV_FILE=data-ingestion-empty-v1.127.0.log \
  TSBS_LOAD_RESULT_CSV_FILE_COMPARE=data-ingestion-empty-pt-index.log
```

</details>

### Non-Empty with Restart

Overall the `pt-index` performance can be noticeably slower than `v1.127.0`
right after the upgrade.

Load summary:

- `v1.127.0`: loaded 1080000000 metrics in 584.077sec with 4 workers (mean rate 1849071.37 metrics/sec)
- `pt-index`: loaded 1080000000 metrics in 651.952sec with 4 workers (mean rate 1656564.17 metrics/sec)

I.e. pt-index is ~11.62% slower.

Below is the graph of the sample load rate over time:

![samples/sec](../perf/data-ingestion-non-empty-after-restart-v1.127.0-pt-index.png)

Comparison of some important metrics

Metric                             | v1.127.0    | pt-index    | diff %
---------------------------------- | ----------- | ----------- | ------
process_cpu_seconds_system_total   | 176.44      | 246.88      | 39.92
process_cpu_seconds_total          | 3558.51     | 3977.55     | 11.77
process_cpu_seconds_user_total     | 3382.07     | 3730.67     | 10.31
process_resident_memory_bytes      | 1738272768  | 1833246720  | 5.46
process_resident_memory_peak_bytes | 2207891456  | 3034320896  | 37.43
process_io_read_bytes_total        | 42104240428 | 42609369274 | 1.2
process_io_written_bytes_total     | 5417114825  | 5852539851  | 8.04

Raw load logs:

- [v1.127.0](../perf/data-ingestion-non-empty-after-restart-v1.127.0.log)
- [pt-index](../perf/data-ingestion-non-empty-after-restart-pt-index.log)

#### How to run

This benchmark depends on data that has been ingested in [previous](#empty) one.

Copy the `v1.127.0` data dir to `pt-index`.

In terminal #2, start `v1.127.0`:

```shell
git checkout v1.127.0
make clean victoria-metrics
./bin/victoria-metrics -storageDataPath=../data
```

In terminal #1, run TSBS data load:

```shell
make tsbs-load-data | tee data-ingestion-non-empty-after-restart-v1.127.0.log
```

Stop `v1.127.0`.

In terminal #3, start `pt-index`:

```shell
git switch issue-7599
make clean victoria-metrics
./bin/victoria-metrics -storageDataPath=../data
```

In terminal #1, run TSBS data load:

```shell
make tsbs-load-data | tee data-ingestion-non-empty-after-restart-pt-index.log
```

Stop `pt-index`.

In terminal #1, plot the graph:

```shell
make tsbs-plot-load \
  TSBS_LOAD_RESULT_CSV_FILE=data-ingestion-non-empty-after-restart-v1.127.0.log \
  TSBS_LOAD_RESULT_CSV_FILE_COMPARE=data-ingestion-non-empty-after-restart-pt-index.log
```

## Index Queries

Index queries are ones that let you retrieve metric or label names, label
values, etc.

This section also includes basic data retrieval. But the data queries used
here are not designed to test the performance various Prom/MetricsQL language
constructs (see [Data Queries](#data-queries) for this). Data retrieval also
involves querying index, and we use simple queries (such as `select *`) to check
the accompanying index queries.

The following use cases are considered:

1. `Before upgrade`. The majority of the users are the existing deployments will
   already have index data at least in the legacy curr indexDB. The perfomance
   of the existing deployments constitutes the baseline that both new that and
   existing deployments that upgraded to pt-index should be compared with.
2. `Right after upgrade`. The upgraded existing deployments will still be using
   the legacy index shortly after upgrade since the pt-index has just started to
   be populated. So it is important to check how queries against legacy curr
   indexDB perform before and right after the upgrade.
3. `Some time after upgrade`. The upgraded existing deployments will continue to
   use legacy index for until it gets rotated out. So it is important to check
   how queries against pt-index and legacy curr indexDB perform when the half of
   the entries are in pt-index and another half is in legacy index.
4. `Long type after upgrade or new`. Some deployments will start from pt-index
   right away. Also, the upgraded existing deployments, will become "pure"
   pt-index deployments when the legacy index is rotated out. Even if both are
   not dealing with entries split between legacy and pt index, it is important
   to check how "pure" pt-index deployments perform compared to legacy index.

For each use case and each index query type, we perform two benchmark:
- Retrieve entries for different number of unique time series (`100`, `1k`,
  `10k`, `100k`, `1M`) on `1d` time range.
- Retrieve entries for `100k` unique time series on different time ranges
  (`1d`, `1w`, `1m`, `2m`, `6m`).

We have performed several benchmark results below is a quick summary based on
manual analysis of all of them. All APIs share the same trends:

- When querying various numbers of unique timeseries, the query performance for
  smaller numbers (<= 10k) can degrade up to 50%. But it is often the same or
  even faster. The performance for higher numbers (100k, 1M) is generally the
  same and can be up to 50% better. This is good given that in a typical
  enterprise deployment the number of unique timeseries in a query response
  often exceeds 100k.
- When querying 100k on various time ranges, the performace generally stays the
  same and can even get better by up to 50%. However on 1m, 2m the performance
  can at times get worse by up to 15%.

Raw results of the three runs:

- [Run 1](../perf/index-queries-v1.127.0-pt-index-run1.log)
- [Run 2](../perf/index-queries-v1.127.0-pt-index-run2.log)
- [Run 3](../perf/index-queries-v1.127.0-pt-index-run3.log)

### How to Run

To test the performance of index queries we use Go benchmarks. Specifically,
we will be using `BenchmarkSearch` located in
`lib/storage/storage_timing_test.go`. It allows to measure the performance of
of most of the vmstorage query API, such as:

- `SearchData` (used in [/api/v1/query_range](https://docs.victoriametrics.com/victoriametrics/url-examples/#apiv1query_range))
- `SeachMetricNames` (used in [/api/v1/series](https://docs.victoriametrics.com/victoriametrics/url-examples/#apiv1series))
- `SearchLabelNames` (used in [/api/v1/labels](https://docs.victoriametrics.com/victoriametrics/url-examples/#apiv1labels))
- `SearchLabelValues` (used in [/api/v1/label/…/values](https://docs.victoriametrics.com/victoriametrics/url-examples/#apiv1labelvalues))
- `SearchTagValueSuffixes` and `SearchGraphitePaths` (used in [/graphite/metrics/find](https://docs.victoriametrics.com/victoriametrics/url-examples/#graphitemetricsfind))

For each query type the same dataset is used. This dataset is ingested once
before a given benchmark and then queried multiple times within the benchmark
loop.

`pt-index` is a big change and it may pontetially affect the index query
performance depending on

- How many unique time series to retrieve from the index
- How big is the query time range
- How index data is split bewteen legacy and pt-index

The benchmark dataset is configurable with this params, i.e.
a given benchmark can specify:

- The number of unique timeseries: `100`, `1k`, `10k`, `100k`, `1M`
- The time range in which data will be contained: `1d`, `1w`, `1m`, `2m`, `6m`
- How index data is split between legacy and pt-index

For example, the following benchmark measures the performance of retrieving `100k`
metrics names within `1d` time range split across legacy curr indexDB and the
partition indexDB:

```
BenchmarkSearch/MetricNames/CurrPt/VariousSeries/1000000
```

And the following one measures the performance of retrieving `100k` metrics
names within `1m` time range that are all in pt-index:

```
BenchmarkSearch/MetricNames/PtOnly/VariousTimeRange/1m
```

To run these benchmarks for all query types.

```
BenchmarkSearch/.*/CurrPt/VariousSeries/1000000
BenchmarkSearch/.*/PtOnly/VariousTimeRange/1m
```

To run this benchmark for all query types for all numbers of unique timeseries
and all time ranges:

```
BenchmarkSearch/.*/CurrPt/VariousMetrics/.*
BenchmarkSearch/.*/PtOnly/VariousTimeRange/.*
```

There can be many combinations and in order to make sense of these results,
let's focus on the use cases that users will be facing after releasing the
pt-index (see above).

For each use case, we will run benchmarks that measures the performance of
queries for different numbers of unique timeseries and different time ranges.
Then, we will compare them.

The benchmarks for the first use case will be run against `v1.127.0`:

```
BenchmarkSearch/.*/CurrOnly/(VariousMetrics|VariousTimeRange)/.*
```

The benchmarks for the rest of use cases will be run against the pt-index:

```
BenchmarkSearch/.*/CurrOnly/(VariousMetrics|VariousTimeRange)/.*
BenchmarkSearch/.*/CurrPt/(VariousMetrics|VariousTimeRange)/.*
BenchmarkSearch/.*/PtOnly/(VariousMetrics|VariousTimeRange)/.*
```

The following script will switch to the necessary tags and branches, run the
benchmarks, and write the comparison results to a file.

```shell
../perf/bench-query
```

## Data Queries

To test data queries we will be using [TSBS](https://github.com/timescale/tsbs).
The test data first needs to be generated and then ingested. Then, 4 concurrent
workers send 1k queries of a given type.

There are 10 [query types](https://github.com/timescale/tsbs?tab=readme-ov-file#devops--cpu-only):

- `single-groupby-1-1-1`
- `single-groupby-1-1-12`
- `single-groupby-1-8-1`
- `single-groupby-5-1-1`
- `single-groupby-5-1-12`
- `single-groupby-5-8-1`
- `cpu-max-all-1`
- `cpu-max-all-8`
- `double-groupby-1`

The following query types are omitted due to being too heavy:
`double-groupby-5`, `double-groupby-all`.

As in [Index Queries](#index-queries), we will consider four use cases:

1. `Before upgrade`
2. `Right after upgrade`
3. `Some time after upgrade`
4. `Long type after upgrade or new`

Benchmark results (queries/s, positive diff is good, negagive - bad):

Query Type            | v1.127.0-CurrOnly | pt-index-CurrOnly | pt-index-CurrPt  | pt-index-PtOnly
--------------------- | ----------------- | ----------------- | ---------------- | ---------------
single-groupby-1-1-1  | 2907.14           | 2610.72  -10.20%  | 2685.45  -7.63%  | 2328.27  -19.91%
single-groupby-1-1-12 | 2537.94           | 2956.71  +16.50%  | 2720.01  +7.17%  | 2695.97  +6.23%
single-groupby-1-8-1  | 2220.44           | 2248.18  +1.25%   | 1354.74  -38.99% | 2071.72  -6.70%
single-groupby-5-1-1  | 1861.04           | 2003.93  +7.68%   | 1423.65  -23.50% | 1105.15  -40.62%
single-groupby-5-1-12 | 1054.75           | 1214.59  +15.15%  | 918.41   -12.93% | 1105.62  +4.82%
single-groupby-5-8-1  | 1324.87           | 1531.3   +15.58%  | 1113.97  -15.92% | 1591.86  +20.15%
cpu-max-all-1         | 852.84            | 968.18   +13.52%  | 894.79   +4.92%  | 1172.26  +37.45%
cpu-max-all-8         | 548.72            | 695.22   +26.70%  | 556.66   +1.45%  | 678.16   +23.59%
double-groupby-1      | 1.46              | 1.47     +0.68%   | 1.29     -11.64% | 1.35     -7.53%

**Summary**: Right after the upgrade (when all entries are in legacy index), the
performace gets even better than it was before the upgrade. However, as the
deployment starts to use pt-index the performance gets worse.

Raw benchmark logs:

- [v1.127.0-CurrOnly](../perf/data-queries-v1.127.0-CurrOnly.log)
- [pt-index-CurrOnly](../perf/data-queries-pt-index-CurrOnly.log)
- [pt-index-CurrPt](../perf/data-queries-pt-index-CurrPt.log)
- [pt-index-PtOnly](../perf/data-queries-pt-index-PtOnly.log)

### How to Run

In terminal #1, build TSBS binaries:

```shell
make tsbs-build
```

In terminal #1, generate test data for the whole previous day, split into two
files. Also generate queries for the whole day:

```shell
make tsbs-generate-data TSBS_START=2025-10-20T00:00:00Z TSBS_END=2025-10-20T11:59:59Z
make tsbs-generate-data TSBS_START=2025-10-20T12:00:00Z TSBS_END=2025-10-20T23:59:59Z
make tsbs-generate-queries-all TSBS_START=2025-10-20T00:00:00Z TSBS_END=2025-10-20T23:59:59Z
```

In terminal #2, start empty instance of `v1.127.0`:

```shell
git checkout v1.127.0
make clean victoria-metrics
rm -Rf ../data/*
./bin/victoria-metrics -storageDataPath=../data
```

In terminal #1, run TSBS data load for two files and then run the queries:

```shell
make tsbs-load-data TSBS_START=2025-10-20T00:00:00Z TSBS_END=2025-10-20T11:59:59Z
make tsbs-load-data TSBS_START=2025-10-20T12:00:00Z TSBS_END=2025-10-20T23:59:59Z
make tsbs-run-queries-all TSBS_START=2025-10-20T00:00:00Z TSBS_END=2025-10-20T23:59:59Z \
  | tee data-queries-v1.127.0-CurrOnly.log
```

Stop `v1.127.0`.

In terminal #3, start `pt-index` on `v1.127.0` data:

```shell
git switch issue-7599
make clean victoria-metrics
./bin/victoria-metrics -storageDataPath=../data
```

In terminal #1, run TSBS queries:

```shell
make tsbs-run-queries-all TSBS_START=2025-10-20T00:00:00Z TSBS_END=2025-10-20T23:59:59Z \
  | tee data-queries-pt-index-CurrOnly.log
```

Stop `pt-index`.

In terminal #2, start empty instance of `v1.127.0` (i.e. previously loaded data
needs to be discasted):

```shell
git checkout v1.127.0
make clean victoria-metrics
rm -Rf ../data/*
./bin/victoria-metrics -storageDataPath=../data
```

In terminal #1, load the first half of the data:

```shell
make tsbs-load-data TSBS_START=2025-10-20T00:00:00Z TSBS_END=2025-10-20T11:59:59Z
```

Stop `v1.127.0`.

In terminal #3, start `pt-index` on `v1.127.0` data:

```shell
git switch issue-7599
make clean victoria-metrics
./bin/victoria-metrics -storageDataPath=../data
```

In terminal #1, load the second half of the data and run the queries:

```shell
make tsbs-load-data TSBS_START=2025-10-20T12:00:00Z TSBS_END=2025-10-20T23:59:59Z
make tsbs-run-queries-all TSBS_START=2025-10-20T00:00:00Z TSBS_END=2025-10-20T23:59:59Z \
  | tee data-queries-pt-index-CurrPt.log
```

Stop `pt-index`.

In terminal #3, start empty `pt-index`:

```shell
git switch issue-7599
rm -Rf ../data/*
make clean victoria-metrics
./bin/victoria-metrics -storageDataPath=../data
```

In terminal #1, run TSBS data load for two files and then run the queries:

```shell
make tsbs-load-data TSBS_START=2025-10-20T00:00:00Z TSBS_END=2025-10-20T11:59:59Z
make tsbs-load-data TSBS_START=2025-10-20T12:00:00Z TSBS_END=2025-10-20T23:59:59Z
make tsbs-run-queries-all TSBS_START=2025-10-20T00:00:00Z TSBS_END=2025-10-20T23:59:59Z \
  | tee data-queries-pt-index-PtOnly.log
```

To extract results from a log:

```shell
cat data-queries-pt-index-PtOnly.log | grep -e 'QUERY_TYPE' -e 'Overall query rate' | grep -v "#" | sed 'N;s/\n/ /g' | awk '{print $3"\t"$15}' | sed 's/TSBS_QUERY_TYPE=//g'
```
