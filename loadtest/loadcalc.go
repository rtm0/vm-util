// loadcalc accepts a subset of
// [Prometheus Benchmark](https://github.com/VictoriaMetrics/prometheus-benchmark)
// config via flags and calculates the corresponding the load for the
// VictoriaMetrics deployment under test test, such as `Ingestion Rate` and
// number of `Active Time Series`.

package main

import (
	"flag"
	"fmt"
	"time"
)

var (
	targetsCount               = flag.Uint64("targetsCount", 1000, "number of instances to scrape")
	scrapeInterval             = flag.Duration("scrapeInterval", 10*time.Second, "how often each instance's metrics are scraped and then ingested")
	scrapeConfigUpdatePercent  = flag.Float64("scrapeConfigUpdatePercent", 1, "the percent of instances that change every scrapeConfigUpdateInterval")
	scrapeConfigUpdateInterval = flag.Duration("scrapeConfigUpdateInterval", 10*time.Minute, "how often the scrapeConfigUpdatePercent of existing instances is replaced with new ones")
	seriesPerTarget            = flag.Uint64("seriesPerTarget", 777, "number of unique metrics exported by a single target")
)

func main() {
	flag.Parse()

	ingestionRate := float64(*targetsCount**seriesPerTarget) / float64(scrapeInterval.Seconds())
	fmt.Println("Ingestion rate", uint64(ingestionRate))

	churnRate1s := float64(*seriesPerTarget**targetsCount) * *scrapeConfigUpdatePercent / 100 / float64(scrapeConfigUpdateInterval.Seconds())
	fmt.Println("Churn rate 1s", uint64(churnRate1s))

	churnRate1h := churnRate1s * 3600
	fmt.Println("Churn rate 1h", uint64(churnRate1h))

	churnRate24h := churnRate1h * 24
	fmt.Println("Churn rate 24h", uint64(churnRate24h))

	// The initial number of active time series.
	// This is the number that the `Active Time Series` chart will show soon
	// after the ingestion starts.
	activeTimeSeriesInitial := *targetsCount * *seriesPerTarget
	fmt.Println("Active time series (initial)", activeTimeSeriesInitial)

	// The effective number of active time series.
	// This is the number that the `Active Time Series` chart will be showing
	// after an hour the ingestion has started.
	activeTimeSeriesEffective := activeTimeSeriesInitial + uint64(churnRate1h)
	fmt.Println("Active time series (effective)", activeTimeSeriesEffective)
}
