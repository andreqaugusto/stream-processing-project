from diagrams import Cluster, Diagram, Edge
from diagrams.custom import Custom
from diagrams.onprem.analytics import Flink
from diagrams.onprem.queue import Kafka
from diagrams.programming.language import Python

ksql_icon = "ksql.jpg"
pinot_icon = "pinot.jpg"

edge = Edge(minlen="2")  # type: ignore

with Diagram("Streaming Project", show=False):
    kafka = Kafka("Kafka Topic\n'transactions'")
    Python("fake_data.py") >> edge >> kafka

    with Cluster("Stream Processing"):
        flink = Flink("Flink")
        ksql = Custom("kSQL", "./ksql.jpg", height="2", width="2", imagescale="width")

    kafka >> edge >> flink >> edge >> Kafka("Kafka Topic\n'transactions_aggregate_flink'")

    (
        kafka
        >> edge
        >> ksql
        >> edge
        >> Kafka("Kafka Topic\n'transactions_aggregate_ksql'")
        >> edge
        >> Custom("Apache Pinot", "./pinot.jpg")
    )
