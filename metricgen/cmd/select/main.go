package main

import (
	"flag"
	"fmt"
	"log/slog"
	"math/rand"
	"os"
	"sync"
	"time"

	"github.com/rtm0/vm-util/metricgen/internal"
)

var (
	addr        = flag.String("vmAddr", "localhost:8428", "vmstorage host:port")
	numMachines = flag.Int("numMachines", 30, "number of machines that export metrics")
	numMetrics  = flag.Int("numMetrics", 500, "number of metrics exported by a machine")
	start       = flag.String("start", "-5m", "the time period from the past until now")
	step        = flag.String("step", "5s", "calculation step")
)

func main() {
	flag.Parse()
	logger := slog.New(slog.NewTextHandler(os.Stdout, nil))
	c := internal.NewClient(logger, *addr, *numMachines)
	var wg sync.WaitGroup
	for machineID := range *numMachines {
		time.Sleep(time.Duration(rand.Intn(1000)) * time.Millisecond)
		wg.Add(1)
		go func() {
			for {
				metricID := rand.Intn(*numMetrics)
				query := fmt.Sprintf(`metric_%d{machine="%d"}`, metricID, machineID)
				c.QueryRange(query, *start, *step)
				time.Sleep(5*time.Second + time.Duration(rand.Intn(1000))*time.Millisecond)
			}
			wg.Done()
		}()
	}
	wg.Wait()
}
