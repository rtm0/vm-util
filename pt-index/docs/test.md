# Partition Index Correctness Testing

## Upgrade-Downgrade-Upgrade

An existing vmcluster deployment is given. The deployment is very close to one
found in prod. It runs in k8s and the data is ingested using the
[Prometheus benchmark](https://github.com/VictoriaMetrics/prometheus-benchmark).
It has been running for a few months already and was switched from pt-index and
back multiple times. For the purity of experiment, we will deploy `v1.127.0` and
let it run for a couple of days.

### 2025-10-16 - 2025-10-19

On `2025-10-16`, deploy `v1.127.0`. Wait until `2025-10-19`.

---

On `2025-10-19`, `v1.127.0` has been running for two full days, `2025-10-17` and
`2025-10-18`. Oct 16th and 19th are not counted because these weren't full days:
the deployment was updated to `v1.127.0` on `2025-10-16` in the afternoon and is
updated to pt-index on of `2025-10-19` in the afternoon.

While still running `v1.127.0`, run index and data queries for `2025-10-17` and
`2025-10-18`:

```shell
../test/query-index-and-data 2025-10-17 v1.127.0
../test/query-index-and-data 2025-10-18 v1.127.0
```

Compare `2025-10-17 v1.127.0` and `2025-10-18 v1.127.0` results. Some timeseries
will change due to churn rate, but the counts for these two days should almost the
same. This check is to set the baseline which the test results that will follow
will be compared against.

---

Upgrade the deployment to the `pt-index` version. Run index and data queries for
`2025-10-17` and `2025-10-18`.

```shell
../test/query-index-and-data 2025-10-17 pt-index
../test/query-index-and-data 2025-10-18 pt-index
```

Compare `2025-10-17 pt-index` with `2025-10-17 v1.127.0`. They should be
identical. Compare `2025-10-17 pt-index` and `2025-10-18 pt-index` results. Some
timeseries will change due to churn rate, but the counts for these two days
should almost the same. These two checks is for showing that pt-index version is
capable of returning full results when the index records are fully in legacy
index.

---

Leave the pt-index version run for one full day.

### 2025-10-19 - 2025-10-21

On `2025-10-21`, `pt-index` has been running for one full day, `2025-10-20`.
This means that all index records for that day will go to pt-index and none to
legacy index.

Additionally, `2025-10-19` index will be partly in legacy index and partly - in
pt-index.

---

While still running `pt-index`, run index and data queries for `2025-10-19`
and `2025-10-20`.

```shell
../test/query-index-and-data 2025-10-19 pt-index
../test/query-index-and-data 2025-10-20 pt-index
```

Compare `2025-10-20 pt-index` results with `2025-10-18 pt-index` results. Some
timeseries will change due to churn rate, but the counts for these two days
should almost the same. This check is to show that pt-index is capable of
returning full results not only when the index records recide fully in legacy
index but also when they are fully in pt-index. In other words, to check that
pt-index version of vmstorage undestands the new index structure it was written
for. No need to compare `2025-10-20 pt-index` with `2025-10-18 v1.127.0` because
we've already compared `2025-10-18 pt-index` with `2025-10-18 v1.127.0`. And if
`2025-10-20 pt-index` is same as `2025-10-18 pt-index` then it is also same as
`2025-10-18 v1.127.0`.

Compare `2025-10-19 pt-index` and `2025-10-20 pt-index` results. Some timeseries
will change due to churn rate, but the counts for these two days should almost
the same. This check is to confirm that pt-index version is capable of full
results when the index records are split between legacy and pt-index. Again, if
previous checks were correct, then `2025-10-19 pt-index` results are also the
same as `2025-10-18 pt-index` and `2025-10-18 v1.127.0`.

---

Downgrade the deployment to `v1.127.0`. Run index and data queries for
`2025-10-19` and `2025-10-20`.

```shell
../test/query-index-and-data 2025-10-19 v1.127.0
../test/query-index-and-data 2025-10-20 v1.127.0
```

Check `2025-10-20 v1.127.0` results. Index query results should be empty. This
shows that `v1.127.0` can't read per-day records from the pt-index. Data query
results, however, may contain partial or even full result. This shows that the
data about metric names is first retrieved from `metricNameCache` and only if
the name is not found there does vmstorage perform the search in legacy index.

Check `2025-10-19 v1.127.0` results. Index query results may be partial or even
full. This is because `2025-10-19` per-day records will be split between legacy
and pt-index. Similarly, the data query results will be partial or even full.

---

Leave the `v1.127.0` run for one full day.

### 2025-10-21 - 2025-10-23

On `2025-10-23`, `pt-index` has been running for one full day, `2025-10-22`.
This means that all index records for that day will go to legacy index and none
to pt-index.

Additionally, `2025-10-21` per-day index will be partly in legacy index and
partly - in pt-index.

While still running `v1.127.0`, run index and data queries for `2025-10-19` and
`2025-10-20` again

```shell
../test/query-index-and-data 2025-10-19 v1.127.0-2
../test/query-index-and-data 2025-10-20 v1.127.0-2
```

Check `2025-10-20 v1.127.0-2` results. Index query results should still be
empty. This shows that if the samples for `2025-10-20` weren't ingested again,
the legacy index will still be lacking the per-day entries. Data query results,
however, will contain less data (compared to `2025-10-19 v1.127.0` results made
two days ago) or even no data. This shows that while the data about metric names
is first retrieved from `metricNameCache`, the cache entries get replaced with
new metrics over time.

Check `2025-10-19 v1.127.0-2` results. Index query results should still be
partial or even full. This is because `2025-10-19` per-day records will be split
between legacy and pt-index. Similarly, the data query results will be partial or
even full.

---

While still running `v1.127.0`, run index and data queries for `2025-10-21` and
`2025-10-22`:

```shell
../test/query-index-and-data 2025-10-21 v1.127.0
../test/query-index-and-data 2025-10-22 v1.127.0
```

Check `2025-10-21 v1.127.0`. The expectations should be similar to
`2025-10-19 v1.127.0` because the per-day entries are split between pt-index and
legacy index.

Compare `2025-10-22 v1.127.0` and `2025-10-18 v1.127.0` results. Some timeseries
will change due to churn rate, but the counts for these two days should almost the
same. This is to show that over time queries against the downgraded deployment
will produce the full result (gaps on dates when pt-index was used will remain,
however).

---

Upgrade the deployment to the `pt-index` version. Run index and data queries for
`2025-10-20`, `2025-10-21`, and `2025-10-22`.

```shell
../test/query-index-and-data 2025-10-20 pt-index-2
../test/query-index-and-data 2025-10-21 pt-index
../test/query-index-and-data 2025-10-22 pt-index
```

Compare `2025-10-20 pt-index-2` with `2025-10-20 pt-index`. The results must be
identical. This is to show that upgrading again after the downgrade will result
in queries returning full results again.

Also check `2025-10-21 pt-index` and `2025-10-22 pt-index`. The results should
be full and comparable to `2025-10-18 pt-index`. This is to show that upgrading
after downgrage will still result in full query results.
