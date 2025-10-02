# Partition Index Correctness Testing

## Upgrade-Downgrade-Upgrade

0.  An existing vmcluster deployment is given. It has been running for at least
    one day. The deployment is very close to one found in prod. It runs in k8s
	and the data is ingested using the
	[Prometheus benchmark](https://github.com/VictoriaMetrics/prometheus-benchmark).

1.  Upgrade to a version with pt index and let it run for a day. Expectations:

    -   The data before and after the upgrade should be searcheable.

2.  Downgrade to previous version and let it run for a day. Expectations:

	-   The data for the new time series that have been ingested while running
	    the pt index version should not be searchable.
	-   The data for the existing time series that have been ingested while
	    running the pt index version may or may not be searchable.

3.  Upgrade to the version with pt index again and let it run for a day.
    Expectations:

    -   All the data becomes searcheable again.
