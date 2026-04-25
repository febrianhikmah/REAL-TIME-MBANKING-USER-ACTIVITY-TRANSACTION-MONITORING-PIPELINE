INSERT INTO daily_transaction_summary (
    transaction_date, transaction_type, total_transactions, successful_transactions,
    failed_transactions, total_amount, avg_amount, max_amount, updated_at
)
SELECT
    DATE(event_timestamp) AS transaction_date,
    transaction_type,
    COUNT(*) AS total_transactions,
    COUNT(*) FILTER (WHERE transaction_status = 'success') AS successful_transactions,
    COUNT(*) FILTER (WHERE transaction_status = 'failed') AS failed_transactions,
    COALESCE(SUM(amount), 0) AS total_amount,
    COALESCE(AVG(amount), 0) AS avg_amount,
    COALESCE(MAX(amount), 0) AS max_amount,
    CURRENT_TIMESTAMP
FROM raw_transaction_events
WHERE transaction_id IS NOT NULL
GROUP BY DATE(event_timestamp), transaction_type
ON CONFLICT (transaction_date, transaction_type) DO UPDATE SET
    total_transactions = EXCLUDED.total_transactions,
    successful_transactions = EXCLUDED.successful_transactions,
    failed_transactions = EXCLUDED.failed_transactions,
    total_amount = EXCLUDED.total_amount,
    avg_amount = EXCLUDED.avg_amount,
    max_amount = EXCLUDED.max_amount,
    updated_at = CURRENT_TIMESTAMP;
