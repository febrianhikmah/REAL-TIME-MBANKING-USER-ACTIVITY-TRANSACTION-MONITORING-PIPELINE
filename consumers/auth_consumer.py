import json

from base_consumer import consume


INSERT_QUERY = """
INSERT INTO raw_auth_events (
    event_id, user_id, account_id, session_id, event_type, channel, device_type,
    device_id, ip_address, city, country, auth_method, failure_reason,
    event_timestamp, metadata
) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
ON CONFLICT (event_id) DO NOTHING;
"""


def map_event(event):
    return (
        event["event_id"],
        event["user_id"],
        event.get("account_id"),
        event["session_id"],
        event["event_type"],
        event.get("channel"),
        event.get("device_type"),
        event.get("device_id"),
        event.get("ip_address"),
        event.get("city"),
        event.get("country"),
        event.get("auth_method"),
        event.get("failure_reason"),
        event["event_timestamp"],
        json.dumps(event.get("metadata", {})),
    )


if __name__ == "__main__":
    consume("banking_auth_events", "auth-events-consumer-group", INSERT_QUERY, map_event, "auth")
