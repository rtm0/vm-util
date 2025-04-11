# Test Cases for https://github.com/VictoriaMetrics/VictoriaMetrics/issues/8134

## 01 Forward compatibility: Data retrieval

### Description

Ensure that the data ingested with legacy indexDB VM can be queried with
partition indexDB VM

### Test Steps

1.  Start legacy vmsingle:

    ```shell
	docker compose -f docker-compose.yml up -d
	```

2.  Ingest data `legacy1` data:

    ```shell
	./8134-api-v1-import-prometheus-legacy1.sh
	```

3. Perform index and data retrieval queries

4. Stop legacy vmsingle

   ```shell
   docker compose -f docker-compose.yml down
   ```

5. Start new vmsingle

    ```shell
	# Uncomment the image and then:
	docker compose -f docker-compose.yml up -d
	```

6. Observe file system changes:

   -   `./indexdb`: only two generations (prev and curr)
   -   `./data` how has `indexdb` dir which currently contains the empty
       partition for the current month (needed when loading the nextDayMetricIDs
	   cache).

6. Perform index and data retrieval queries

7. Stop new vmsingle

   ```shell
   docker compose -f docker-compose.yml down
   ```

### Expected Result

See steps section.

### Actual Result

See steps section.

### Cleanup

```shell
sudo rm -Rf ~/tmp/demo2/*
```

## 02 Forward compatibility: Data Ingestion

### Description

Verify that new vmsingle is able to continue to ingest new data on top of the
existing data ingested with legacy vmsingle. Also observe the behavior of legacy
vmsingle run on data ingested with the new vmsingle.

### Test Steps

1.  Start new vmsingle:

    ```shell
	# Change the image and then:
	docker compose -f docker-compose.yml up -d
	```

3.  Ingest `new1` data  and more `legacy1` data:

    ```shell
	./8134-api-v1-import-prometheus-new1.sh
	./8134-api-v1-import-prometheus-legacy1-continue.sh
	```

4.  Observe changes on file system:

    -   `data/indexdb` now has two more parititions.

5.  Perform index and data retrieval queries

6.  Stop new vmsingle

    ```shell
	docker compose -f docker-compose.yml down
	```

7.  Start legacy vmsingle

    ```shell
	# Change the image and then:
	docker compose -f docker-compose.yml up -d
	```

8.  Observe changes on file system:

    -   `data/indexdb` remains
	-   `./indexdb` now has 3 generations: prev, curr, and next

9.  Perform index and data queries

    -   Legacy vmsingle won't return any results for `new1` index entries
	    created with new vmsingle. However, data queries will return non-empty
		result. This is because data queries will use `metricID->MetricName`
		cache instead of index.
	-   `legacy1` index entries on the time range created by new vmsingle won't
	    be shown

10. Stop legacy vmsingle:

    ```shell
	docker compose -f docker-compose.yml down
	```

### Expected Result

See steps section.

### Actual Result

See steps section.

### Cleanup

```shell
sudo rm -Rf ~/tmp/demo2/*
```
