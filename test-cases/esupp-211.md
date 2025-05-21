# VMAgent should support Kafka 4.0

## 01 Verify that vmagent-v1.117.1-enterprise supports reading from and writing to Kafka < 4.0

### Description

Configure two Kafka topics a VMAgent that pulls from one topic and pushes to
another.

See:
-   https://kafka.apache.org/quickstart
-   https://docs.victoriametrics.com/victoriametrics/vmagent/#kafka-integration

### Test Steps

1.  Setup Kafka:

    ```shell
	wget https://dlcdn.apache.org/kafka/3.9.1/kafka_2.13-3.9.1.tgz
	tar xvf kafka_2.13-3.9.1.tgz
	cd kafka_2.13-3.9.1
	KAFKA_CLUSTER_ID="$(bin/kafka-storage.sh random-uuid)"
	bin/kafka-storage.sh format --standalone -t $KAFKA_CLUSTER_ID -c config/server.properties

	bin/zookeeper-server-start.sh config/zookeeper.properties
	bin/kafka-server-start.sh config/server.properties

	bin/kafka-topics.sh --bootstrap-server=localhost:9092 --create --topic in
	bin/kafka-topics.sh --bootstrap-server=localhost:9092 --create --topic out
	bin/kafka-topics.sh --bootstrap-server=localhost:9092 --list
	```

2. Setup VMAgent:

3. Write data to Kafka `in` topic:

4. Observe VMAgent logs and metrics showing that data was read from and written
   to Kafka:

5. Read data from Kafka `out` topic:


### Expected Result

VMAgent passes data from Kafka1 to Kafka2

### Actual Result

TODO

### Cleanup

TODO
