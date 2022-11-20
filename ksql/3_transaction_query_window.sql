CREATE OR REPLACE TABLE windowed_transactions 
WITH (kafka_topic='windowed_transactions')
AS 
  SELECT
         '1' AS dummy,
         WINDOWSTART AS window_start,
         WINDOWEND AS window_end,
         SUM(total_paid) AS total_paid,
         COUNT(*) AS total_transactions,
         SUM(total_paid)/COUNT(*) AS average_transaction_value
  FROM paid_transactions_stream
  WINDOW TUMBLING (SIZE 3 SECONDS)
  GROUP BY '1'
  EMIT CHANGES;