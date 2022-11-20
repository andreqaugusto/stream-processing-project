import json
import logging
import multiprocessing as mp
import random
import time
import uuid
from datetime import datetime as dt
from functools import partial
from typing import Optional

import click
from faker import Faker
from kafka import KafkaProducer

HOST = ["localhost:9092"]
TOPIC = "transactions"
STATIC_IDS = [
    "14660caf-508e-42bf-8cc5-c4b9a576a6ac",
    "245d2676-04f8-4036-bc25-1a9b02bb75f1",
    "357a63c8-e1f6-4adf-8a54-25e78ef6a0f0",
    "4536beb6-b9b1-4fdf-b248-41807cd5b080",
    "58c405ab-535e-4d25-b76a-7d6cab8adcd1",
    "6dce3cca-2bf1-488a-8e43-6f05e15ae84f",
    "7c0284d-d1a4-44ab-9e32-b4d61a586f35",
    "8d1417e6-9429-4220-9874-14e475aed9d2",
    "93e01ba4-861c-4e1e-9ae8-b0e317214c24",
    "071a417f-b4df-487d-8bd3-d54c7ad14672",
]

CONFIG = {
    "acks": "all",
    "bootstrap_servers": HOST,
    "key_serializer": lambda key: str(key).encode(encoding="utf-8"),
    "value_serializer": lambda data: json.dumps(data).encode(encoding="utf-8"),
}


# Define log format
logging.basicConfig(
    level=logging.WARNING,  # set to warning to avoid KafkaProducer logs in the terminal
    format="%(asctime)s - %(levelname)s - %(message)s",
    datefmt="%Y-%d-%mT%H:%M:%S",
)


def __data_producer(static_data: bool = True, sleep: Optional[float] = 0.3) -> tuple:
    """
    Function to produce Fake data. If `static_data = True`, then it will select Fake data from a
    list of 10 random UUIDs. Then
    """
    user_id, total_paid = None, None
    fake_data = Faker()
    time_now = dt.now()
    time_now_string = time_now.isoformat(sep=" ", timespec="milliseconds")
    if static_data:
        idx = random.randint(1, 10)
        user_id = STATIC_IDS[idx - 1]
        total_paid = idx * 10

    key = user_id or str(uuid.uuid4())
    value = {
        "event_timestamp": time_now_string,
        "user_id": key,
        "transaction_id": random.randint(1, 1000000),
        "total_paid": total_paid or random.randint(20, 500),
        "status": fake_data.random_element(elements=("Paid", "Refused")),
    }

    if sleep:
        time.sleep(sleep)

    return key, value


def __sender(iteration: int, topic: str, number: int) -> bool:
    """
    Function that sends the data to Kafka
    """
    producer = KafkaProducer(**CONFIG)
    key, value = __data_producer()
    try:
        producer.send(topic=topic, key=key, value=value)
    except Exception as e:
        logging.error(f"Fail to deliver message {iteration}/{number} - {str(e)}")
        return False
    else:
        logging.warning(f"Message {iteration}/{number} delivered")
        return True


@click.command(help="Utility to generate Fake Data to a Local Kafka cluster.")
@click.option(
    "--topic",
    nargs=1,
    type=str,
    required=False,
    default=TOPIC,
    help="The local Kafka topic to send the data.",
)
@click.option(
    "--number",
    nargs=1,
    type=int,
    required=True,
    help="The number of events that are going to be sent to Kafka.",
)
def main(topic: str, number: int) -> None:
    """
    Function to send Fake Events to Kafka
    """
    logging.warning(f"Starting to send {number} events to topic {topic}")

    start_time = time.time()
    partial_data_sender = partial(__sender, topic=topic, number=number)

    with mp.Pool(processes=10) as pool:
        result = pool.map(partial_data_sender, range(1, number + 1))

    delivered = len([response for response in result if response])
    logging.warning(f"Total Messages delivered: {delivered}/{number}")
    duration = time.time() - start_time
    print(f"Duration: {duration:.2f} seconds")


if __name__ == "__main__":
    main()
