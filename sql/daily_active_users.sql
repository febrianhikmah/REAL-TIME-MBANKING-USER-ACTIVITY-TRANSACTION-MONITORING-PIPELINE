WITH all_user_activity AS (
    SELECT user_id, event_timestamp, 'auth' AS event_domain FROM raw_auth_events
    UNION ALL
    SELECT user_id, event_timestamp, 'account' AS event_domain FROM raw_account_events
    UNION ALL
    SELECT user_id, event_timestamp, 'transaction' AS event_domain FROM raw_transaction_events
    UNION ALL
    SELECT user_id, event_timestamp, 'security' AS event_domain FROM raw_security_events
),
aggregated AS (
    SELECT
        DATE(event_timestamp) AS activity_date,
        COUNT(DISTINCT user_id) AS active_users,
        COUNT(*) AS total_events,
        COUNT(*) FILTER (WHERE event_domain = 'auth') AS auth_events,
        COUNT(*) FILTER (WHERE event_domain = 'account') AS account_events,
        COUNT(*) FILTER (WHERE event_domain = 'transaction') AS transaction_events,
        COUNT(*) FILTER (WHERE event_domain = 'security') AS security_events
    FROM all_user_activity
    GROUP BY DATE(event_timestamp)
)
INSERT INTO daily_active_banking_users (
    activity_date, active_users, total_events, auth_events, account_events,
    transaction_events, security_events, updated_at
)
SELECT
    activity_date, active_users, total_events, auth_events, account_events,
    transaction_events, security_events, CURRENT_TIMESTAMP
FROM aggregated
ON CONFLICT (activity_date) DO UPDATE SET
    active_users = EXCLUDED.active_users,
    total_events = EXCLUDED.total_events,
    auth_events = EXCLUDED.auth_events,
    account_events = EXCLUDED.account_events,
    transaction_events = EXCLUDED.transaction_events,
    security_events = EXCLUDED.security_events,
    updated_at = CURRENT_TIMESTAMP;
