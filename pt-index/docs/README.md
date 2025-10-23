# Victoria Metrics Partition Index

Upgrading to `v1.TBD.0` will automatically switch the existing deployments to
the partition index (or `pt-index` for short). The purpose of this change is to
reduce disk space occupied by index. Namely, index is now stored and removed
along with the corresponding partition. See:
https://github.com/VictoriaMetrics/VictoriaMetrics/issues/7599

Only new deployments, however, will be able to benefit from this change from the
start. The existing deployments will start seeing benefits only after the legacy
index becomes outside the retention period and gets deleted.

There is no way to opt out of this feature but neither any upgrade preparations
are required from the end users. `Just upgrading the version` should work since
we've made sure the feature is forward-compatible with the existing deployments.
See below [what to expect after upgrade](#what-to-expect-after-upgrade).

Backward compatibility, however, is not guaranteed. While switching back to a
previous version is possible, there are certain cases when data that was
ingested while using partition index will become invisible. See below [what to
expect after downgrade](#what-to-expect-after-downgrade).

## What to expect after upgrade

### Per-partition indexDB

Each partition will have its own indexDB. On the filesystem, this will manifest
as the `indexDB` directory in under the `data` directory.

Before:

```
storageDataPath
├── data
│   ├── big
│   │   ├── 2025_01
│   │   ├── ...
│   │   ├── 2025_10
│   └── small
│       ├── 2025_01
│       ├── ...
│       ├── 2025_10
├── indexdb
```

After:

```
storageDataPath
├── data
│   ├── big
│   │   ├── 2025_01
│   │   ├── ...
│   │   ├── 2025_10
│   ├── indexdb
│   │   ├── 2025_10
│   └── small
│       ├── 2025_01
│       ├── ...
│       ├── 2025_10
├── indexdb
```

An indexDB is created for a given partition as soon as vmstorage receives the
first sample that belongs to that partition. This means that existing
deployments that switched to pt-index will have partition indexDBs only for
those partitions that they have received samples for after the upgrade. In the
example above, the deployment has 10 partitions, but only the last one has
a corresponding indexDB because previous partitions did not receive any samples
after the upgrade. The rest of the index is till stored in
`storageDataPath/indexdb` which we will be calling `legacy indexDB(s)` from now
on.

There is no prefill or background migration from legacy to partition indexDBs.
But vmstorage will create missing records in pt-index as new samples are
ingested, both for existing timeseries and new ones. For existing timeseries,
the metricIDs will be reused if they are found in `tsidCache`. This may
initially slow down the ingestion (see the
[Data Ingestion](perf.md#data-ingestion) benchmark results).

This is true only for existing deployments that switched to pt-index. New
deployments that started to use pt-index right away won't have legacy indexDBs
at all.

### Legacy indexDBs become read-only (almost)

After the upgrade of an existing deployment, legacy indexDBs will not be deleted
but they will stop receving new entries right away and will be used for querying
only.

During data retrieval, legacy and partition indexDBs will be queried
concurrently. At first, most of the entries will be found in legacy indexDBs,
but over time, as the partition index is filled in and new partitions are
created, most of the index data will be coming from pt-index. See
[Index Queries](perf.md#index-queries) and [Data Queries](perf.md#data-queries)
benchmark results for different use cases.

Legacy indexDBs will not become fully read-only though. It is possible that new
entries will be added to them when a timeseries is
[deleted](https://docs.victoriametrics.com/victoriametrics/url-examples/#apiv1admintsdbdelete_series).
For this reason, background merges in legacy indexDBs are still possible.

A legacy indexDB gets deleted when it becomes fully outside the retention
period. New legacy indexDBs are not created. Once the last legacy indexDB is
deleted, the deployment will fully switch to pt-index.

You may have noticed that legacy indexDB has 3 generations: `prev`, `curr`, and
`next`. On the file system, these correspond to three subdirs in the
`storageDataPath/indexdb` dir. After the upgrade, the `next` indexDB will be
removed and only 2 subdirs will remain.

### Persistent caches

Sometimes, a new feature requires resetting certain persistent caches. Below is
the full list of such caches that provides a brief description of each cache and
what will happen to them after the update.

`tsidCache`. Stores `metricName-to-TSID` mappings, used for speeding up the
ingestion and reusing metricIDs for the same metricNames, persisted to
`cache/metricName_tsid` file, named as `storage/tsid` on Grafana dashboard. The
cache will not be reset and will be used for re-using metricIDs for existing
timeseries. Also, unlike in previous versions, the cache will not be reset after
timeseries deletion.

`metricNameCache`. Stores `metricID-to-metricName` mappings, used for speeding
up data and index queries,  persisted to `cache/metricID_metricName` file, named
as `storage/metricName` on Grafana dashboard. The cache will not be reset.

`metricIDCache`. Stores `metricID-to-TSID` mappings, used for speeding up data
queries, persisted to `cache/metricID_tsid` file, named as `storage/metricIDs`
on Grafana dashboard. The cache will not be reset.

`metricTracker`. Stores metric name usage stats, persisted to
`cache/metric_usage_tracker` file, named as `storage/metricNamesStatsTracker` on
Gragana dashboard. The cache will not be reset.

`prevHourMetricIDs` and `currHourMetricIDs`. Store unique metricIDs of ingested
samples whose timestamps belongs to the previous and current hour, used for
reporting `active timeseries` metric on Grafana dashboard, persisted to
`cache/prev_hour_metric_ids` and `cache/curr_hour_metric_ids`. These caches will
be reset because creating index records relies on their contents. Since there is
no way to tell which indexDB the cache contents belongs to, two different file
will be used to persist these caches: `cache/prev_hour_metric_ids_v2` and
`cache/curr_hour_metric_ids_v2`. On Grafana dasboards this will be reflected as
a drop in active timeseries. This drop will be back to normal in an hour.

`nextDayMetricIDs`. Stores metrics during the next day index prefill, used for
speeding up the sample ingestion during the last hour of the day, persisted to
`cache/next_day_metric_ids_v2` file. This cache will be reset because the
metricIDs it contains correspond to the legacy indexDB.

### Backup/restore

Making backups and restoring from backups should work between versions. For
example:

- Backups made before upgrade, can safely be restored after upgrading to
  pt-index.
- Backups made after the upgrade, can safely be restored after downgrading to a
  version without pt-index.

No changes have been made to backup/restore binaries. And it is safe to use
older backup/restore binaries to backup/restore pt-index data and use new
backup/restore binaries to backup/restore data produced by the older version
without pt-index support.

## What to expect after downgrade

After upgrading to pt-index version, vmstorage will start writing index entries
to pt-index for both new and existing timeseries. Since previous versions do not
know about pt-index and can only search the legacy index, downgrading will cause
that some timeseries ingested after upgrade won't be found on some time ranges
after the downgrade.

It is important to note, that downgrade will not cause any data to get corrupted
or deleted. It just won't be possible to query that data because older versions
do not know about the pt-index. How much data will become invisible depends on
the churn rate and how much time the pt-index version was used. And upgrading to
pt-index after downgrade will make all the data visible again.

Below are few examples.

If the pt-index was used for a whole day, index and data queries for that day
may return partial or no results at all:

- Regardless of churn rate, index queries (such as getting the list of series
  names, or label names, or label values) will return no results. This is
  because vmstorage will perform per-day index lookup in the legacy indexDB and
  it will be missing all the records for that day.
- Regardless of churn rage, data queries (instant or range) will still return
  partial (or even all) results, because the metric names will first be read
  from `metricNameCache` before performing legacy indexDB lookup. If all the
  metric names can be found in cache, then the response will be full, otherwise
  it will be partial or even empty.

Churn rate becomes important when the pt-index was used for less than one day,
say for couple of hours. In this case some records for that day are present in
legacy index already and will be added to it after the downgrade as the new
samples arrive.

- If there is no churn rate, index queries will return either 1) full result
  right away (because per-day legacy index already have all the timeseries for
  that day) or 2) partial result at first and full result later as the new
  samples arrive and thus populate the index with missing timeseries.
- If there is high churn rate, there can be timeseries that appeared and then
  dissappeared while pt-index was in use. These timeseries will become fully
  invisible for index queries. Data queries will may still return something due
  to caching.

We have performed the `upgrage-downgrade-upgrade` test in our sandbox. Steps and
results can be found [here](test.md#upgrade-downgrade-upgrade).
