CREATE OR REPLACE STREAM paid_transactions_stream AS
  SELECT
    event_timestamp, 
    transaction_id, 
    user_id,
    total_paid
  FROM transactions_stream
  WHERE status = 'Paid';


