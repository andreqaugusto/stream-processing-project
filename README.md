# Stream Processing Project

This is a personal project that I started with the goal to study and use some of the most used stream-processing technologies.

## Technologies Used
- [x] Apache Kafka
- [x] KSQL
- [x] Apache Pinot
- [ ] Apache Beam (with Apache Flink as backend)
- [ ] Apache Spark
- [ ] Apache Superset

## Architecture

Using the Python library `faker`, we create fake `transaction` data to simulate a generic e-commerce. Our main goal is to aggregate those transactions in 3-second windows to know our income in real-time.

The data is produced by the `fake_data.py` script. One can notice that we hard-coded a list of 10 `user_id`s. This was done to help debugging and ensure correctness of our stream pipelines, since each `user_id` start with a number from 0 to 9 and the each user pays a fixed amount equal to ten times its leading number (with `0` being interpreted as `10`). As an example, the user with leading number `5` will pay always pay the amount of `50`.

As of today, the project architecture is simple:

```
kafka (topic transactions) -> kSQL -> Apache Pinot
```

As we can see in the [Techonologies](#technologies) section, we intend to add `beam` and `Spark` as other stream-processing technologies and `Superset` as a visualization layer.

## Instructions

In order to run the project, just run the command `make project`. This will start all the docker containers and generate all the necessary resources in each container.

Once all resources are created, run `make data N=number` to send `number` of messages to `Kafka`. The script will send the `number` messages using 10 parallel processes. 

![Sending Data](imgs/make_data.png)

You can visualize the messages sent on the Kafka UI at [localhost:8080](localhost:8080). The messages are sent to the `transactions` topic. `KSQL` stores the aggregations at the `window_transactions` topic.

![Messages in Kafka](imgs/kafka_messages.png)

Then, you can see the resulting tables in `pinot` in the `pinot-controller` interface at [localhost:9000](localhost:9000).

![Data in Pinot](imgs/pinot_table.png)

If needed, more commands are available in the `Makefile`.

## Notes & Learnings

- We need to send a key to Kafka topic in order to use `table` (topic #6 in https://www.confluent.io/blog/troubleshooting-ksql-part-1/)
- The `ROWTIME` pseudo-column available in `kSQL`: https://docs.ksqldb.io/en/latest/developer-guide/ksqldb-reference/create-stream/#rowtime

## Design Choices

We delibery chose to **not** use default Docker images of said technologies. Since each one can be download and run locally, we chose to do (almost) the same thing using Docker containers. This allowed us to know more about the configurations available in each one (as one can see in the `config`) folder.

## References
- https://www.confluent.io/blog/real-time-analytics-with-kafka-and-pinot/
- https://docs.pinot.apache.org/basics/getting-started/running-pinot-in-docker