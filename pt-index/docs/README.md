# Victoria Metrics Partition Index

Upgrading to `v1.TBD.0` will automatically switch the existing deployments to
the partition index (or `pt-index` for short). The purpose of this change is to
reduce disk space occupied by index. Namely, index is now stored and removed
along with the corresponding partition. See:
https://github.com/VictoriaMetrics/VictoriaMetrics/issues/7599

Only new deployments, however, will be able to benefit from this change from the
start. The existing deployments will start seeing benefits only after the legacy
index becomes outside the retention period and deleted.

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
after the upgrade. The rest of the index is till stored under
`storageDataPath/data/indexdb` which we from now on call `legacy indexDB(s)`.

There is no prefill or background migration from legacy to partition indexDBs.
But vmstorage will create missing records in pt-index as new samples are
ingested, both for existing timeseries and new ones. For existing timeseries,
the metricIDs will be reused if they are found in `tsidCache`.

TODO(@rtm0): Will it cause ingestion slowdown?

This is true only for existing deployments that switched to pt-index. New
deployments that started to use pt-index right away won't have legacy indexDBs
at all.

### Legacy indexDBs become read-only (almost)

After the upgrade of an existing deployment, legacy indexDBs will not deleted
but they will stop receving new entries right away and will be used for querying
only.

During data retrieval, legacy and partition indexDBs will be queried
concurrently. At first, most of the entries will be found in legacy indexDBs,
but over time, as the partition index is filled in and new partitions are
created, most of the index data will be coming from pt-index. See
[benchmark results](#perf.md) for different cases.

Legacy indexDBs will not become fully read-only though. It is possible that new
entries will be added to to them when a timeseries is deleted. For this reason
background merges in legacy indexDBs are still possible.

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
reporting `active timeseries` metric on Grafana dashboard. These caches will not
be reset.

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
after the downgrade. It is important to note, that the data is not deleted it
just can't be queried because older versions can't query partition index. How
much data will become invisible depends on the churn rate and how much time the
pt-index version was used.

Some examples:

- **No churn rate and pt-index was used for less than a whole day**. After
  downgrade, it will still be possible to query all data because the all index
  records will be found in the legacy index because no new timeseries were
  registered.
- **No churn rate and pt-index was used for more than a whole day**. After
  downgrade, no data will be found for that day if the query time range is
  <= 40 days. Even if no new timeseries were registered, vmstorage will read
  per-day index entries for that day and will find none. However, if the time
  range is > 40 days, it will find the data for that day because it will be
  using global index entries.
- **High churn rate and pt-index was used for less than a whole day**. After the
  downgrade, new metrics that appeared and then disappeared during the use of
  pt-index, will not be visible. Metrics that appeared during the use of
  pt-index and still "alive" after the downgrade won't be visible at first, but
  will gradually start to be visible as the new samples arrive.
- **High churn rate and pt-index was used for more than a whole day**.
  Similarly, after the downgrade, new metrics that appeared and then disappeared
  during the use of pt-index, will not be visible. Metrics that appeared during
  the use of pt-index and still "alive" after the downgrade won't be visible for
  that day if the query time range is <= 40 days. But if the new samples arrive
  and the time range is > 40 days, the data for those metrics will become
  visible for queries again.
