import click
from kafka import KafkaConsumer

HOST = ["localhost:9092"]

CONFIG = {
    "bootstrap_servers": HOST,
    "auto_offset_reset": "earliest",
}


@click.command(help="CLI to start a consumer for a local Kafka cluster")
@click.argument(
    "topic",
    nargs=1,
    type=str,
    required=True,
)
def consumer(topic: str):

    kafka_consumer = KafkaConsumer(topic, **CONFIG, group_id="local")
    for msg in kafka_consumer:
        print(msg)

if __name__ == "__main__":
    consumer()
