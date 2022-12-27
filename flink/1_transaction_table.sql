CREATE OR REPLACE TABLE transactions_table
  ( 
    event_timestamp TIMESTAMP(3), 
    transaction_id INT, 
    user_id STRING,
    total_paid INT, 
    status STRING,
    flink_timestamp TIMESTAMP(3) METADATA FROM 'timestamp',
    WATERMARK FOR event_timestamp AS event_timestamp
  )
  WITH (
  'connector' = 'kafka',
  'topic' = 'transactions',
  'properties.bootstrap.servers' = 'kafka:29092',
  'properties.group.id' = 'flink',
  'scan.startup.mode' = 'earliest-offset',
  'format' = 'json'
  );


