WITH all_events AS (
    SELECT user_id, session_id, event_timestamp, event_type, 'auth' AS event_domain, NULL::VARCHAR AS transaction_status
    FROM raw_auth_events
    UNION ALL
    SELECT user_id, session_id, event_timestamp, event_type, 'account' AS event_domain, NULL::VARCHAR AS transaction_status
    FROM raw_account_events
    UNION ALL
    SELECT user_id, session_id, event_timestamp, event_type, 'transaction' AS event_domain, transaction_status
    FROM raw_transaction_events
    UNION ALL
    SELECT user_id, session_id, event_timestamp, event_type, 'security' AS event_domain, NULL::VARCHAR AS transaction_status
    FROM raw_security_events
    WHERE session_id IS NOT NULL
),
aggregated AS (
    SELECT
        DATE(event_timestamp) AS activity_date,
        session_id,
        MIN(user_id) AS user_id,
        MIN(event_timestamp) AS first_event_at,
        MAX(event_timestamp) AS last_event_at,
        EXTRACT(EPOCH FROM MAX(event_timestamp) - MIN(event_timestamp))::INTEGER AS session_duration_seconds,
        COUNT(*) AS total_events,
        COUNT(*) FILTER (WHERE event_domain = 'transaction') AS transaction_events,
        COUNT(*) FILTER (WHERE event_domain = 'transaction' AND transaction_status = 'success') AS successful_transactions,
        COUNT(*) FILTER (WHERE event_domain = 'security') > 0 AS has_security_event
    FROM all_events
    GROUP BY DATE(event_timestamp), session_id
)
INSERT INTO banking_session_summary_daily (
    activity_date, session_id, user_id, first_event_at, last_event_at,
    session_duration_seconds, total_events, transaction_events,
    successful_transactions, has_security_event, updated_at
)
SELECT
    activity_date, session_id, user_id, first_event_at, last_event_at,
    session_duration_seconds, total_events, transaction_events,
    successful_transactions, has_security_event, CURRENT_TIMESTAMP
FROM aggregated
ON CONFLICT (activity_date, session_id) DO UPDATE SET
    user_id = EXCLUDED.user_id,
    first_event_at = EXCLUDED.first_event_at,
    last_event_at = EXCLUDED.last_event_at,
    session_duration_seconds = EXCLUDED.session_duration_seconds,
    total_events = EXCLUDED.total_events,
    transaction_events = EXCLUDED.transaction_events,
    successful_transactions = EXCLUDED.successful_transactions,
    has_security_event = EXCLUDED.has_security_event,
    updated_at = CURRENT_TIMESTAMP;
