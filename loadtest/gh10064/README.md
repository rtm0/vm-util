# https://github.com/VictoriaMetrics/VictoriaMetrics/issues/10064

Load per vmstorage replica:

- Active time series: 15M
- Churn rate 1s: ~50
- Churn rate 24h: 4M
- Ingestion rate: 1.5M

Then, for 2 vmstorage replicas:

- Active time series: 30M
- Churn rate 1s: ~100
- Churn rate 24h: 8M
- Ingestion rate: 3M

```shell
go run ../loadcalc.go -seriesPerTarget=777 --targetsCount=38150 -scrapeInterval=10s -scrapeConfigUpdatePercent=0.02 -scrapeConfigUpdateInterval=1m
Ingestion rate 2964255
Churn rate 1s 98
Churn rate 1h 355710
Churn rate 24h 8537054
Active time series (initial) 29642550
Active time series (effective) 29998260
```
