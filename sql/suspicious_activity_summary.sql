WITH security_events AS (
    SELECT
        DATE(event_timestamp) AS activity_date,
        user_id,
        COUNT(*) FILTER (WHERE event_type = 'suspicious_activity_detected') AS suspicious_event_count,
        COUNT(*) FILTER (WHERE event_type = 'device_changed') AS new_device_login_count,
        MAX(risk_score) AS max_security_risk_score
    FROM raw_security_events
    GROUP BY DATE(event_timestamp), user_id
),
high_value_transactions AS (
    SELECT
        DATE(event_timestamp) AS activity_date,
        user_id,
        COUNT(*) AS high_value_transaction_count,
        COALESCE(SUM(amount), 0) AS total_high_value_amount,
        MAX((metadata ->> 'risk_score')::INTEGER) AS max_transaction_risk_score
    FROM raw_transaction_events
    WHERE event_type = 'high_value_transaction' OR amount >= 10000000
    GROUP BY DATE(event_timestamp), user_id
),
combined AS (
    SELECT
        COALESCE(s.activity_date, h.activity_date) AS activity_date,
        COALESCE(s.user_id, h.user_id) AS user_id,
        COALESCE(s.suspicious_event_count, 0) AS suspicious_event_count,
        COALESCE(h.high_value_transaction_count, 0) AS high_value_transaction_count,
        COALESCE(s.new_device_login_count, 0) AS new_device_login_count,
        COALESCE(h.total_high_value_amount, 0) AS total_high_value_amount,
        GREATEST(
            COALESCE(s.max_security_risk_score, 0),
            COALESCE(h.max_transaction_risk_score, 0)
        ) AS max_risk_score
    FROM security_events s
    FULL OUTER JOIN high_value_transactions h
        ON s.activity_date = h.activity_date
        AND s.user_id = h.user_id
)
INSERT INTO suspicious_activity_summary_daily (
    activity_date, user_id, suspicious_event_count, high_value_transaction_count,
    new_device_login_count, total_high_value_amount, max_risk_score, risk_level, updated_at
)
SELECT
    activity_date,
    user_id,
    suspicious_event_count,
    high_value_transaction_count,
    new_device_login_count,
    total_high_value_amount,
    max_risk_score,
    CASE
        WHEN max_risk_score >= 80 OR total_high_value_amount >= 50000000 THEN 'high'
        WHEN max_risk_score >= 50 OR high_value_transaction_count >= 2 THEN 'medium'
        ELSE 'low'
    END AS risk_level,
    CURRENT_TIMESTAMP
FROM combined
ON CONFLICT (activity_date, user_id) DO UPDATE SET
    suspicious_event_count = EXCLUDED.suspicious_event_count,
    high_value_transaction_count = EXCLUDED.high_value_transaction_count,
    new_device_login_count = EXCLUDED.new_device_login_count,
    total_high_value_amount = EXCLUDED.total_high_value_amount,
    max_risk_score = EXCLUDED.max_risk_score,
    risk_level = EXCLUDED.risk_level,
    updated_at = CURRENT_TIMESTAMP;
