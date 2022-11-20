CREATE OR REPLACE STREAM transactions_stream
  ( 
    event_timestamp STRING, 
    transaction_id INT, 
    user_id STRING,
    total_paid INT, 
    status STRING
  )
  WITH (
    kafka_topic='transactions', 
    value_format='json', 
    timestamp='event_timestamp', 
    timestamp_format='yyyy-MM-dd HH:mm:ss.SSS'
    );


