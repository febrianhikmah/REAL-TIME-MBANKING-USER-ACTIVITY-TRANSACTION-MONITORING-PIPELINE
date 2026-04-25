import json
import os
import time

from kafka import KafkaProducer

from event_factory import make_event


TOPIC_MAP = {
    "auth": "banking_auth_events",
    "account": "banking_account_events",
    "transaction": "banking_transaction_events",
    "security": "banking_security_events",
}

KEY_FIELD_MAP = {
    "auth": "user_id",
    "account": "account_id",
    "transaction": "account_id",
    "security": "user_id",
}


def build_producer():
    return KafkaProducer(
        bootstrap_servers=os.getenv("KAFKA_BOOTSTRAP_SERVERS", "localhost:29092"),
        value_serializer=lambda value: json.dumps(value).encode("utf-8"),
        key_serializer=lambda value: value.encode("utf-8"),
        retries=5,
    )


def main():
    interval_seconds = float(os.getenv("PRODUCER_INTERVAL_SECONDS", "1"))
    producer = build_producer()
    print("Banking event producer started")

    while True:
        event = make_event()
        category = event["event_category"]
        topic = TOPIC_MAP[category]
        key = event[KEY_FIELD_MAP[category]]
        producer.send(topic, key=key, value=event)
        producer.flush()
        print(f"Produced {event['event_type']} to {topic}: {event['event_id']}")
        time.sleep(interval_seconds)


if __name__ == "__main__":
    main()
