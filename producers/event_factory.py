import random
import uuid
from datetime import datetime, timezone


CITIES = ["Jakarta", "Bandung", "Surabaya", "Medan", "Denpasar", "Yogyakarta"]
CHANNELS = ["mobile_banking", "internet_banking"]
DEVICE_TYPES = ["mobile", "desktop"]
AUTH_METHODS = ["biometric", "password", "pin", "otp"]
FAILURE_REASONS = ["wrong_password", "expired_otp", "account_locked", "insufficient_balance"]
BANKS = ["BCA", "Mandiri", "BRI", "BNI", "CIMB Niaga", "Permata"]
MERCHANT_CATEGORIES = ["food_and_beverage", "transport", "utilities", "retail", "travel"]


def _now_iso():
    return datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")


def _base_event(category):
    user_num = random.randint(1001, 9999)
    device_type = random.choice(DEVICE_TYPES)
    return {
        "event_id": str(uuid.uuid4()),
        "event_category": category,
        "user_id": f"user_{user_num}",
        "account_id": f"acct_{user_num}",
        "session_id": f"session_{random.randint(100000, 999999)}",
        "channel": random.choice(CHANNELS),
        "device_type": device_type,
        "device_id": f"device_{random.randint(1000, 9999)}",
        "ip_address": f"103.{random.randint(10, 99)}.{random.randint(10, 99)}.{random.randint(1, 254)}",
        "city": random.choice(CITIES),
        "country": "Indonesia",
        "event_timestamp": _now_iso(),
    }


def make_auth_event():
    event_type = random.choices(
        ["login_success", "login_failed", "logout", "password_changed"],
        weights=[55, 25, 15, 5],
    )[0]
    event = _base_event("auth")
    event.update(
        {
            "event_type": event_type,
            "auth_method": random.choice(AUTH_METHODS),
            "failure_reason": random.choice(FAILURE_REASONS) if event_type == "login_failed" else None,
            "metadata": {
                "app_version": random.choice(["5.4.1", "5.4.2", "5.5.0"]),
                "risk_score": random.randint(5, 80 if event_type == "login_failed" else 35),
            },
        }
    )
    return event


def make_account_event():
    event_type = random.choice(["balance_inquiry", "account_statement_viewed"])
    event = _base_event("account")
    event.update(
        {
            "event_type": event_type,
            "screen_name": "account_statement" if event_type == "account_statement_viewed" else "account_overview",
            "statement_period": random.choice(["last_7_days", "last_30_days", "last_90_days"])
            if event_type == "account_statement_viewed"
            else None,
            "metadata": {"risk_score": random.randint(1, 25)},
        }
    )
    return event


def make_transaction_event():
    event_type = random.choices(
        [
            "transfer_initiated",
            "transfer_completed",
            "transfer_failed",
            "bill_payment_completed",
            "qr_payment_completed",
            "high_value_transaction",
        ],
        weights=[15, 35, 10, 18, 17, 5],
    )[0]
    transaction_type = {
        "bill_payment_completed": "bill_payment",
        "qr_payment_completed": "qr_payment",
    }.get(event_type, random.choice(["internal_transfer", "interbank_transfer"]))
    amount = random.randint(10000, 5000000)
    if event_type == "high_value_transaction":
        amount = random.randint(10000000, 100000000)
    event = _base_event("transaction")
    status = "success"
    if event_type == "transfer_initiated":
        status = "pending"
    elif event_type == "transfer_failed":
        status = "failed"
    event.update(
        {
            "event_type": event_type,
            "transaction_id": f"trx_{random.randint(700000, 999999)}",
            "transaction_type": transaction_type,
            "amount": amount,
            "currency": "IDR",
            "transaction_status": status,
            "beneficiary_type": random.choice(["saved_recipient", "new_recipient"])
            if transaction_type.endswith("transfer")
            else None,
            "bank_destination": random.choice(BANKS) if transaction_type == "interbank_transfer" else None,
            "merchant_id": f"merchant_{random.randint(1000, 9999)}" if transaction_type == "qr_payment" else None,
            "merchant_category": random.choice(MERCHANT_CATEGORIES) if transaction_type == "qr_payment" else None,
            "failure_reason": random.choice(FAILURE_REASONS) if status == "failed" else None,
            "metadata": {"auth_method": random.choice(AUTH_METHODS), "risk_score": random.randint(10, 95)},
        }
    )
    return event


def make_security_event():
    event_type = random.choice(["device_changed", "suspicious_activity_detected"])
    risk_score = random.randint(45, 98)
    event = _base_event("security")
    event.update(
        {
            "event_type": event_type,
            "related_transaction_id": f"trx_{random.randint(700000, 999999)}"
            if event_type == "suspicious_activity_detected"
            else None,
            "trigger_rule": "new_recipient_high_value_transaction"
            if event_type == "suspicious_activity_detected"
            else "new_device_login",
            "risk_score": risk_score,
            "risk_level": "high" if risk_score >= 80 else "medium",
            "metadata": {
                "reason": "Synthetic fraud signal",
                "old_device_id": f"device_{random.randint(1000, 9999)}",
            },
        }
    )
    return event


def make_event():
    factory = random.choices(
        [make_auth_event, make_account_event, make_transaction_event, make_security_event],
        weights=[35, 20, 35, 10],
    )[0]
    return factory()
