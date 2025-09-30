#!/bin/bash

BENCHMARKS=(
	BenchmarkStorageAddRows_VariousTimeRanges
)


BENCHMARKS2=(
  BenchmarkStorageAddRows \
  BenchmarkStorageAddRows_VariousTimeRanges \
  BenchmarkStorageInsertWithAndWithoutPerDayIndex \
  BenchmarkStorageSearchMetricNames_VariousTimeRanges \
  BenchmarkStorageSearchLabelNames_VariousTimeRanges \
  BenchmarkStorageSearchLabelValues_VariousTimeRanges \
  BenchmarkStorageSearchTagValueSuffixes_VariousTimeRanges \
  BenchmarkStorageSearchGraphitePaths_VariousTimeRanges \
  BenchmarkSearch_VariousTimeRanges
)
