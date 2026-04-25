CREATE TABLE IF NOT EXISTS raw_auth_events (
    event_id UUID PRIMARY KEY,
    user_id VARCHAR(100) NOT NULL,
    account_id VARCHAR(100),
    session_id VARCHAR(100) NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    channel VARCHAR(50),
    device_type VARCHAR(50),
    device_id VARCHAR(100),
    ip_address VARCHAR(50),
    city VARCHAR(100),
    country VARCHAR(100),
    auth_method VARCHAR(50),
    failure_reason VARCHAR(100),
    event_timestamp TIMESTAMP NOT NULL,
    metadata JSONB,
    inserted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS raw_account_events (
    event_id UUID PRIMARY KEY,
    user_id VARCHAR(100) NOT NULL,
    account_id VARCHAR(100) NOT NULL,
    session_id VARCHAR(100) NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    channel VARCHAR(50),
    device_type VARCHAR(50),
    device_id VARCHAR(100),
    ip_address VARCHAR(50),
    city VARCHAR(100),
    country VARCHAR(100),
    screen_name VARCHAR(100),
    statement_period VARCHAR(50),
    event_timestamp TIMESTAMP NOT NULL,
    metadata JSONB,
    inserted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS raw_transaction_events (
    event_id UUID PRIMARY KEY,
    user_id VARCHAR(100) NOT NULL,
    account_id VARCHAR(100) NOT NULL,
    session_id VARCHAR(100) NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    channel VARCHAR(50),
    device_type VARCHAR(50),
    device_id VARCHAR(100),
    ip_address VARCHAR(50),
    city VARCHAR(100),
    country VARCHAR(100),
    transaction_id VARCHAR(100),
    transaction_type VARCHAR(100),
    amount NUMERIC(18, 2),
    currency VARCHAR(10),
    transaction_status VARCHAR(50),
    beneficiary_type VARCHAR(50),
    bank_destination VARCHAR(100),
    merchant_id VARCHAR(100),
    merchant_category VARCHAR(100),
    failure_reason VARCHAR(100),
    event_timestamp TIMESTAMP NOT NULL,
    metadata JSONB,
    inserted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS raw_security_events (
    event_id UUID PRIMARY KEY,
    user_id VARCHAR(100) NOT NULL,
    account_id VARCHAR(100),
    session_id VARCHAR(100),
    event_type VARCHAR(100) NOT NULL,
    channel VARCHAR(50),
    device_type VARCHAR(50),
    device_id VARCHAR(100),
    ip_address VARCHAR(50),
    city VARCHAR(100),
    country VARCHAR(100),
    related_transaction_id VARCHAR(100),
    trigger_rule VARCHAR(100),
    risk_score INTEGER,
    risk_level VARCHAR(50),
    event_timestamp TIMESTAMP NOT NULL,
    metadata JSONB,
    inserted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_raw_auth_user_ts ON raw_auth_events (user_id, event_timestamp);
CREATE INDEX IF NOT EXISTS idx_raw_account_user_ts ON raw_account_events (user_id, event_timestamp);
CREATE INDEX IF NOT EXISTS idx_raw_transaction_user_ts ON raw_transaction_events (user_id, event_timestamp);
CREATE INDEX IF NOT EXISTS idx_raw_security_user_ts ON raw_security_events (user_id, event_timestamp);
