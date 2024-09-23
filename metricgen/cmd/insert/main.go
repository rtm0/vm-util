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
	writeURL    = flag.String("writeURL", "http://localhost:8428/api/v1/import/prometheus", "vmstorage write URL")
	numMachines = flag.Int("numMachines", 50, "number of machines exporting metrics")
	numMetrics  = flag.Int("numMetrics", 2000, "number of metrics exported by each machine")
	churnRate   = flag.Int("churnRate", 10, "number of new metrics per second")
)

func main() {
	flag.Parse()

	logger := slog.New(slog.NewTextHandler(os.Stdout, nil))
	c := internal.NewClient(logger, &internal.ClientOptions{
		MaxConns: *numMachines,
		WriteURL: *writeURL,
	})
	generations := make([][]int, *numMachines)
	genCh := make(chan struct{}, *churnRate*5)
	var wg sync.WaitGroup
	for machineID := range *numMachines {
		generations[machineID] = make([]int, *numMetrics)
		wg.Add(1)
		go func() {
			time.Sleep(time.Duration(rand.Intn(1000)) * time.Millisecond)

			t := time.NewTicker(1 * time.Second)
			for {
				d := data(machineID, generations[machineID], genCh)
				select {
				case <-t.C:
					c.Write(d)
				}
			}

			wg.Done()
		}()
	}

	go func() {
		t := time.NewTicker(1 * time.Second)
		for {
			select {
			case <-t.C:
				for range *churnRate {
					genCh <- struct{}{}
				}
			}
		}
	}()

	wg.Wait()
}

func data(machineID int, generations []int, genCh chan struct{}) string {
	var sb strings.Builder
	for metricID := range *numMetrics {
		select {
		case <-genCh:
			generations[metricID]++
		default:
		}
		value := rand.Intn(100)
		gen := generations[metricID]
		sb.WriteString(fmt.Sprintf(`metric_%d{machine="%d",generation="%d"} %d`, metricID, machineID, gen, value))
		sb.WriteString("\n")
	}
	return sb.String()
}
