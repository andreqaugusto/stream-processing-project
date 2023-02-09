import pyspark.sql.functions as F
import pyspark.sql.types as T
from pyspark.sql import SparkSession

spark = (
    SparkSession.builder.appName("transaction_aggregate_spark")
    .master("spark://spark:7077")
    .getOrCreate()
)

# reduce logging
spark.sparkContext.setLogLevel("WARN")

df = (
    spark.readStream.format("kafka")
    .option("kafka.bootstrap.servers", "kafka:29092")
    .option("subscribe", "transactions")
    .load()
)

# need to cast the value of the Kafka message into STRING, since they come into as bytes
# see https://spark.apache.org/docs/latest/structured-streaming-kafka-integration.html#reading-data-from-kafka
value_string = df.selectExpr("CAST(value AS STRING) AS val")

# creating the schema to parse the `value_string` dataframe
schema = T.StructType(
    [
        T.StructField("event_timestamp", T.StringType()),
        T.StructField("transaction_id", T.IntegerType()),
        T.StructField("user_id", T.StringType()),
        T.StructField("total_paid", T.IntegerType()),
        T.StructField("status", T.StringType()),
    ]
)

# creating the dataframe
transactions = value_string.select(F.from_json(F.col("val"), schema).alias("parsed_value"))
transactions = transactions.select(F.col("parsed_value.*"))

# filtering
transactions_paid = transactions.filter("status = 'Paid'")

# aggregating
transactions_window = transactions_paid.groupBy(F.window("event_timestamp", "3 seconds")).agg(
    F.sum(F.col("total_paid")).alias("total_paid"),
    F.count(F.col("user_id")).alias("total_transactions"),
)

# creating the `window_start` and `window_end` columns
transactions_window = transactions_window.select(
    F.col("window.start").alias("window_start"),
    F.col("window.end").alias("window_end"),
    *[col for col in transactions_window.columns if col != "window"],
)

# creating the `average_transaction_value` column
transactions_window = transactions_window.withColumn(
    "average_transaction_value", F.col("total_paid") / F.col("total_transactions")
)

## since we are not using watermarks, we can't use 'append' mode, only 'update'/'complete'
## see doc: https://spark.apache.org/docs/latest/structured-streaming-programming-guide.html#output-modes

# writing the results to Kafka
sink = (
    # needing to come back as key/value to write into kafka
    transactions_window.selectExpr("CAST(TO_JSON(STRUCT(*)) AS string) AS value")
    .writeStream.format("kafka")
    .option("kafka.bootstrap.servers", "kafka:29092")
    .option("topic", "transactions_aggregate_spark")
    .option("checkpointLocation", "/tmp/spark/checkpoint")
    .outputMode("update")
    .start()
    .awaitTermination()
)
