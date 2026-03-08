all: clean build

clean:
	rm -Rf ./bin

build:
	go build -o bin/loadgen ./cmd/loadgen

run: build
	./bin/loadgen \
	    -metrics=./data/metrics.txt -instances=10 \
	    -qps=10 -concurrency=10 \
	    -lookbackWindow=1h \
	    -queryRangeURL=http://localhost:8481/select/0/prometheus/api/v1/query_range
