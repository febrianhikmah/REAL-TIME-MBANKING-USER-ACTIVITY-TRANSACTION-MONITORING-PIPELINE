CREATE TABLE IF NOT EXISTS daily_active_banking_users (
    activity_date DATE PRIMARY KEY,
    active_users INTEGER,
    total_events INTEGER,
    auth_events INTEGER,
    account_events INTEGER,
    transaction_events INTEGER,
    security_events INTEGER,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS daily_transaction_summary (
    transaction_date DATE,
    transaction_type VARCHAR(100),
    total_transactions INTEGER,
    successful_transactions INTEGER,
    failed_transactions INTEGER,
    total_amount NUMERIC(18, 2),
    avg_amount NUMERIC(18, 2),
    max_amount NUMERIC(18, 2),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (transaction_date, transaction_type)
);

CREATE TABLE IF NOT EXISTS failed_login_summary_daily (
    activity_date DATE,
    user_id VARCHAR(100),
    failed_login_count INTEGER,
    distinct_ip_count INTEGER,
    distinct_device_count INTEGER,
    is_risky BOOLEAN,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (activity_date, user_id)
);

CREATE TABLE IF NOT EXISTS suspicious_activity_summary_daily (
    activity_date DATE,
    user_id VARCHAR(100),
    suspicious_event_count INTEGER,
    high_value_transaction_count INTEGER,
    new_device_login_count INTEGER,
    total_high_value_amount NUMERIC(18, 2),
    max_risk_score INTEGER,
    risk_level VARCHAR(50),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (activity_date, user_id)
);

CREATE TABLE IF NOT EXISTS banking_session_summary_daily (
    activity_date DATE,
    session_id VARCHAR(100),
    user_id VARCHAR(100),
    first_event_at TIMESTAMP,
    last_event_at TIMESTAMP,
    session_duration_seconds INTEGER,
    total_events INTEGER,
    transaction_events INTEGER,
    successful_transactions INTEGER,
    has_security_event BOOLEAN,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (activity_date, session_id)
);
