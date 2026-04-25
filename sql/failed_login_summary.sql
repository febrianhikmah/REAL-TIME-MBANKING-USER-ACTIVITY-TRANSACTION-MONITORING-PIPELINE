INSERT INTO failed_login_summary_daily (
    activity_date, user_id, failed_login_count, distinct_ip_count,
    distinct_device_count, is_risky, updated_at
)
SELECT
    DATE(event_timestamp) AS activity_date,
    user_id,
    COUNT(*) AS failed_login_count,
    COUNT(DISTINCT ip_address) AS distinct_ip_count,
    COUNT(DISTINCT device_id) AS distinct_device_count,
    CASE
        WHEN COUNT(*) >= 5 THEN TRUE
        WHEN COUNT(DISTINCT ip_address) >= 3 THEN TRUE
        WHEN COUNT(DISTINCT device_id) >= 3 THEN TRUE
        ELSE FALSE
    END AS is_risky,
    CURRENT_TIMESTAMP AS updated_at
FROM raw_auth_events
WHERE event_type = 'login_failed'
GROUP BY DATE(event_timestamp), user_id
ON CONFLICT (activity_date, user_id) DO UPDATE SET
    failed_login_count = EXCLUDED.failed_login_count,
    distinct_ip_count = EXCLUDED.distinct_ip_count,
    distinct_device_count = EXCLUDED.distinct_device_count,
    is_risky = EXCLUDED.is_risky,
    updated_at = CURRENT_TIMESTAMP;
