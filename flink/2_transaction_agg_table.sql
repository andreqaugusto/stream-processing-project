CREATE OR REPLACE TABLE transactions_paid_agg_table
  ( 
    window_start TIMESTAMP(3), 
    window_end TIMESTAMP(3), 
    total_paid INT,
    total_transactions BIGINT, 
    average_transaction_value BIGINT
  )
  WITH (
  'connector' = 'kafka',
  'topic' = 'transactions_aggregate_flink',
  'properties.bootstrap.servers' = 'kafka:29092',
  'properties.allow.auto.create.topics' = 'true',
  'format' = 'json'
  );