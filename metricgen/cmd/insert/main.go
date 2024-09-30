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
	writeURL      = flag.String("writeURL", "http://localhost:8428/api/v1/import/prometheus", "vmstorage write URL")
	metricPattern = flag.String("metricPattern", `metric_%d{machine="%d",generation="%d"} %d`, "a metric pattern that accepts four integers")
	numMachines   = flag.Int("numMachines", 50, "number of machines exporting metrics")
	numMetrics    = flag.Int("numMetrics", 2000, "number of metrics exported by each machine")
	churnRate     = flag.Int("churnRate", 0, "number of new metrics per second (0 means no churn rate)")
	sendOnce      = flag.Bool("once", false, "if true each machine will send its metrics only once")
	dryRun        = flag.Bool("dryRun", false, "if true, write metrics to stdout without sending")
)

func main() {
	flag.Parse()

	f := writeToStdout
	if !*dryRun {
		logger := slog.New(slog.NewTextHandler(os.Stdout, nil))
		c := internal.NewClient(logger, &internal.ClientOptions{
			MaxConns: *numMachines,
			WriteURL: *writeURL,
		})
		f = c.Write
	}

	generations := make([][]int, *numMachines)
	initGen := int(time.Now().Unix())
	for machineID := range *numMachines {
		generations[machineID] = make([]int, *numMetrics)
		for metricID := range *numMetrics {
			generations[machineID][metricID] = initGen
		}
	}

	genCh := make(chan struct{}, *churnRate*5)
	var wg sync.WaitGroup
	for machineID := range *numMachines {
		wg.Add(1)
		go func(writeFunc func(string)) {
			defer wg.Done()
			time.Sleep(time.Duration(rand.Intn(1000)) * time.Millisecond)

			t := time.NewTicker(1 * time.Second)
			for {
				d := data(machineID, generations[machineID], genCh)
				select {
				case <-t.C:
					writeFunc(d)
					if *sendOnce {
						return
					}
				}
			}

		}(f)
	}

	if *churnRate > 0 {
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
	}

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
		sb.WriteString(fmt.Sprintf(*metricPattern, metricID, machineID, gen, value))
		sb.WriteString("\n")
	}
	return sb.String()
}

func writeToStdout(data string) {
	fmt.Printf("%s", data)
}
