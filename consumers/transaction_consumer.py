import json

from base_consumer import consume


INSERT_QUERY = """
INSERT INTO raw_transaction_events (
    event_id, user_id, account_id, session_id, event_type, channel, device_type,
    device_id, ip_address, city, country, transaction_id, transaction_type,
    amount, currency, transaction_status, beneficiary_type, bank_destination,
    merchant_id, merchant_category, failure_reason, event_timestamp, metadata
) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
ON CONFLICT (event_id) DO NOTHING;
"""


def map_event(event):
    return (
        event["event_id"],
        event["user_id"],
        event["account_id"],
        event["session_id"],
        event["event_type"],
        event.get("channel"),
        event.get("device_type"),
        event.get("device_id"),
        event.get("ip_address"),
        event.get("city"),
        event.get("country"),
        event.get("transaction_id"),
        event.get("transaction_type"),
        event.get("amount"),
        event.get("currency"),
        event.get("transaction_status"),
        event.get("beneficiary_type"),
        event.get("bank_destination"),
        event.get("merchant_id"),
        event.get("merchant_category"),
        event.get("failure_reason"),
        event["event_timestamp"],
        json.dumps(event.get("metadata", {})),
    )


if __name__ == "__main__":
    consume(
        "banking_transaction_events",
        "transaction-events-consumer-group",
        INSERT_QUERY,
        map_event,
        "transaction",
    )
