from datetime import datetime, timedelta
from pathlib import Path

from airflow import DAG
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator


DEFAULT_ARGS = {
    "owner": "data-engineering",
    "depends_on_past": False,
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}


def load_sql(filename):
    return (Path("/opt/airflow/sql") / filename).read_text()


with DAG(
    dag_id="banking_session_summary",
    default_args=DEFAULT_ARGS,
    start_date=datetime(2026, 1, 1),
    schedule="@daily",
    catchup=False,
    tags=["banking", "analytics", "sessions"],
) as dag:
    refresh_banking_session_summary = SQLExecuteQueryOperator(
        task_id="refresh_banking_session_summary",
        conn_id="postgres_banking_activity",
        sql=load_sql("banking_session_summary.sql"),
    )
