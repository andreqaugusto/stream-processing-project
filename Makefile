.PHONY: flink ksql spark

dev: 
	docker compose --profile all up -d --build

stop:
	docker compose --profile all down

project:
	make stop
	make dev
	@sleep 5
	make create-kafka-topic topic=transactions
	make create-kafka-topic topic=transactions_aggregate_ksql
	make create-kafka-topic topic=transactions_aggregate_flink
	make create-kafka-topic topic=transactions_aggregate_spark
	@sleep 10
	make run-spark-job
	@sleep 10
	make create-ksql-resources
	@sleep 10
	make create-pinot-table

data:
	python ./producer/fake_data.py --number $(N)

create-kafka-topic:
	docker exec -t kafka /opt/kafka/bin/kafka-topics.sh --bootstrap-server kafka:29092 \
  		--partitions=3 --replication-factor=1 --create --topic $(topic)

create-ksql-resources:
	python ./ksql/create_resources.py

create-pinot-table:
	docker exec -t pinot-server /opt/pinot/bin/pinot-admin.sh AddTable \
		-schemaFile /usr/pinot/schema.json \
		-tableConfigFile /usr/pinot/table.json \
		-controllerHost pinot-controller -controllerPort 9000 \
		-exec

flink: 
	docker compose --profile flink up -d --build
	make create-kafka-topic topic=transactions
	make create-kafka-topic topic=transactions_aggregate_flink

flink-sql:
	docker compose run -it flink-sql

kafka: 
	docker compose --profile kafka up -d --build

ksql: 
	docker compose --profile ksql up -d --build
	make create-kafka-topic topic=transactions
	make create-kafka-topic topic=transactions_aggregate_ksql

ksql-cli:
	docker compose run -it ksql-cli

pinot-cli:
	docker exec -it pinot-controller bash

pinot:
	docker compose run pinot-server -d

run-spark-job:
	docker exec -d spark ./bin/spark-submit \
	 --packages org.apache.spark:spark-sql-kafka-0-10_2.12:3.3.1 \
	 /app/jobs/transaction_job.py

spark: 
	docker compose --profile spark up -d --build
	make create-kafka-topic topic=transactions
	make create-kafka-topic topic=transactions_aggregate_spark

