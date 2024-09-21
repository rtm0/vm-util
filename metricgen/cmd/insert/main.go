package main

import (
	"flag"
	"fmt"
	"log/slog"
	"math/rand"
	"os"
	"strings"
	"sync"
	"time"

	"github.com/rtm0/vm-util/metricgen/internal"
)

var (
	addr        = flag.String("vmAddr", "localhost:8428", "vmstorage host:port")
	numMachines = flag.Int("numMachines", 50, "number of machines exporting metrics")
	numMetrics  = flag.Int("numMetrics", 2000, "number of metrics exported by each machine")
	churnRate   = flag.Int("churnRate", 5, "metric churn rate in seconds")
)

func main() {
	flag.Parse()

	logger := slog.New(slog.NewTextHandler(os.Stdout, nil))
	c := internal.NewClient(logger, *addr, *numMachines)
	var wg sync.WaitGroup
	for machineID := range *numMachines {
		wg.Add(1)
		go func() {
			time.Sleep(time.Duration(rand.Intn(1000)) * time.Millisecond)
			t := time.NewTicker(1 * time.Second)
			for {
				d := data(machineID)
				select {
				case <-t.C:
					c.Insert(d)
				}
			}
			wg.Done()
		}()
	}
	wg.Wait()
}

func data(machineID int) string {
	generation := int(time.Now().Unix()) / *churnRate
	var sb strings.Builder
	for metricID := range *numMetrics {
		value := rand.Intn(100)
		sb.WriteString(fmt.Sprintf(`metric_%d{machine="%d",generation="%d"} %d`, metricID, machineID, generation, value))
		sb.WriteString("\n")
	}
	return sb.String()
}
