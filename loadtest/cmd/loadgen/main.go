package main

import (
	"flag"
	"log/slog"
	"os"
	"os/signal"
	"sync"
	"syscall"
	"time"

	"github.com/rtm0/vm-util/loadtest/internal"
)

var (
	queriesFilePath = flag.String("queries", "", "path to file containing MetricsQL queries")
	metricsFilePath = flag.String("metrics", "", "path to file containing metrics names to be used in queries")
	numInstances    = flag.Int("instances", 10, "number of instances that emit metrics from -metrics file")
	lookbackWindow  = flag.Duration("lookbackWindow", 1*time.Hour, "how far the queries should look in the past starting from now")
	concurrency     = flag.Int("concurrency", 10, "number of queries send concurrently")
	qps             = flag.Int("qps", 10, "number of queries to send per second")
	queryRangeURL   = flag.String("queryRangeURL", "http://localhost:8481/select/0/prometheus/api/v1/query_range", "URL where to send queries")
)

func main() {
	flag.Parse()
	logger := slog.New(slog.NewJSONHandler(os.Stdout, nil))
	qgen, err := internal.NewQueryGenerator(logger, internal.QueryGeneratorOptions{
		QueriesFilePath: *queriesFilePath,
		MetricsFilePath: *metricsFilePath,
		NumInstances:    *numInstances,
	})
	if err != nil {
		logger.Error("could not create query generator", "error", err)
		os.Exit(1)
	}

	var wg sync.WaitGroup
	stopCh := make(chan struct{})
	rateLimitCh := make(chan struct{}, *qps)
	queryCh := make(chan string)

	// Create rate limiter.
	wg.Add(1)
	go func() {
		ticker := time.NewTicker(time.Second)
		defer ticker.Stop()
		for {
			select {
			case <-stopCh:
				close(rateLimitCh)
				logger.Info("rate limiter stopped")
				wg.Done()
				return
			case <-ticker.C:
				var full bool
				for token := 0; token < *qps && !full; token++ {
					select {
					case rateLimitCh <- struct{}{}:
					default:
						full = true
						logger.Warn("rate limiter not all tokens were used", "got", token, "want", *qps)
					}
				}
			}
		}
	}()

	// Create query generator.
	wg.Add(1)
	go func() {
		for {
			select {
			case <-rateLimitCh:
				queryCh <- qgen.NextQuery()
			case <-stopCh:
				close(queryCh)
				logger.Info("query generator stopped")
				wg.Done()
				return
			}
		}
	}()

	// Create workers.
	cli := internal.NewClient(logger, internal.ClientOptions{
		MaxConns:      *concurrency,
		QueryRangeURL: *queryRangeURL,
	})
	for i := range *concurrency {
		wg.Add(1)
		go func() {
			for query := range queryCh {
				start := time.Now().Add(-*lookbackWindow)
				cli.QueryRange(query, start)
			}
			logger.Info("worker stopped", "id", i)
			wg.Done()
		}()
	}

	// Wait until SIGINT or SIGTERM is received.
	signalCh := make(chan os.Signal, 1)
	signal.Notify(signalCh, os.Interrupt, syscall.SIGTERM)
	<-signalCh
	close(stopCh)
	wg.Wait()

	logger.Info("load generator stopped gracefully")
}
