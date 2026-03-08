package internal

import (
	"bufio"
	"fmt"
	"log/slog"
	"os"
)

type QueryGenerator struct {
	logger *slog.Logger

	queries      []string
	nextQueryIdx int

	metrics       []string
	numInstances  int
	nextMetricIdx int
	nextInstance  int
}

type QueryGeneratorOptions struct {
	QueriesFilePath string
	MetricsFilePath string
	NumInstances    int
}

func NewQueryGenerator(logger *slog.Logger, opts QueryGeneratorOptions) (*QueryGenerator, error) {
	qgen := &QueryGenerator{
		logger: logger,
	}

	var err error
	if opts.QueriesFilePath != "" {
		qgen.queries, err = loadFromFile(logger, opts.QueriesFilePath)
	} else {
		qgen.numInstances = opts.NumInstances
		qgen.metrics, err = loadFromFile(logger, opts.MetricsFilePath)
	}

	if err != nil {
		return nil, err
	}
	return qgen, nil
}

func loadFromFile(logger *slog.Logger, path string) ([]string, error) {
	f, err := os.Open(path)
	if err != nil {
		return nil, err
	}
	defer f.Close()

	var lines []string
	s := bufio.NewScanner(f)
	for s.Scan() {
		lines = append(lines, s.Text())
	}

	if err := s.Err(); err != nil {
		return nil, err
	}

	return lines, nil
}

func (qgen *QueryGenerator) NextQuery() string {
	var query string

	if len(qgen.queries) > 0 {
		i := qgen.nextQueryIdx
		query = qgen.queries[i]

		if i < len(qgen.queries)-1 {
			i++
		} else {
			i = 0
		}
		qgen.nextQueryIdx = i
	} else {
		i, j := qgen.nextMetricIdx, qgen.nextInstance
		query = fmt.Sprintf("%s{instance=\"host-%d\"}", qgen.metrics[i], j)

		if i < len(qgen.metrics)-1 {
			i++
		} else {
			i = 0
			if j < qgen.numInstances-1 {
				j++
			} else {
				j = 0
			}
		}
		qgen.nextMetricIdx, qgen.nextInstance = i, j
	}

	return query
}
