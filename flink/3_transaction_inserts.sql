INSERT INTO transactions_paid_agg_table
SELECT 
  window_start,
  window_end,
  SUM(total_paid) AS total_paid,
  COUNT(*) AS total_transactions,
  SUM(total_paid)/COUNT(*) AS average_transaction_value
FROM TABLE(TUMBLE(TABLE transactions_table, DESCRIPTOR(event_timestamp), INTERVAL '3' SECONDS))
WHERE status = 'Paid'
GROUP BY window_start, window_end;