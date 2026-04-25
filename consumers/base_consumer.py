import json
import os
import time

import psycopg2
from kafka import KafkaConsumer


DB_CONFIG = {
    "host": os.getenv("POSTGRES_HOST", "localhost"),
    "database": os.getenv("POSTGRES_DB", "banking_activity_db"),
    "user": os.getenv("POSTGRES_USER", "postgres"),
    "password": os.getenv("POSTGRES_PASSWORD", "postgres"),
    "port": int(os.getenv("POSTGRES_PORT", "5432")),
}


def connect_with_retry():
    while True:
        try:
            return psycopg2.connect(**DB_CONFIG)
        except psycopg2.OperationalError as exc:
            print(f"Postgres unavailable, retrying in 5s: {exc}")
            time.sleep(5)


def build_consumer(topic, group_id):
    return KafkaConsumer(
        topic,
        bootstrap_servers=os.getenv("KAFKA_BOOTSTRAP_SERVERS", "localhost:29092"),
        auto_offset_reset="earliest",
        enable_auto_commit=True,
        group_id=group_id,
        value_deserializer=lambda value: json.loads(value.decode("utf-8")),
    )


def consume(topic, group_id, insert_query, value_mapper, label):
    conn = connect_with_retry()
    cursor = conn.cursor()
    consumer = build_consumer(topic, group_id)
    print(f"{label} consumer started on {topic}")

    for message in consumer:
        event = message.value
        try:
            cursor.execute(insert_query, value_mapper(event))
            conn.commit()
            print(f"Inserted {label} event: {event['event_id']}")
        except Exception as exc:
            conn.rollback()
            print(f"Failed to insert {label} event {event.get('event_id')}: {exc}")
