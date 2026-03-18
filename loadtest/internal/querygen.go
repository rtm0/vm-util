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

	var numQueries int
	if opts.QueriesFilePath != "" {
		queries, err := loadUniqLinesFromFile(logger, opts.QueriesFilePath)
		if err != nil {
			return nil, err
		}
		numQueries = len(queries)
		qgen.queries = queries
	} else if opts.MetricsFilePath != "" {
		if opts.NumInstances <= 0 {
			return nil, fmt.Errorf("unexpected number of instances: got %d, want > 0", opts.NumInstances)
		}
		metrics, err := loadUniqLinesFromFile(logger, opts.MetricsFilePath)
		if err != nil {
			return nil, err
		}
		numQueries = len(metrics) * opts.NumInstances
		qgen.metrics = metrics
		qgen.numInstances = opts.NumInstances
	} else {
		return nil, fmt.Errorf("no queries or metrics file path has been provided")
	}

	logger.Info("created query generator", "num_uniq_queries", numQueries)
	return qgen, nil
}

func loadUniqLinesFromFile(logger *slog.Logger, path string) ([]string, error) {
	f, err := os.Open(path)
	if err != nil {
		return nil, err
	}
	defer f.Close()

	var (
		lines     []string
		sizeBytes int
	)
	seen := make(map[string]bool)
	s := bufio.NewScanner(f)
	for s.Scan() {
		l := s.Text()
		if !seen[l] {
			seen[l] = true
			lines = append(lines, l)
			sizeBytes += len(l)
		}
	}

	if err := s.Err(); err != nil {
		return nil, err
	}

	if len(lines) == 0 {
		return nil, fmt.Errorf("file must contain at least one line: %s", path)
	}

	logger.Info("loaded", "file", path, "uniq_lines", len(lines), "size_bytes", sizeBytes)
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
