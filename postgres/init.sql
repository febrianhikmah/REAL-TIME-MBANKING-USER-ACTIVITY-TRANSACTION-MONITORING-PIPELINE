\set ON_ERROR_STOP on

SELECT 'CREATE DATABASE airflow_db'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'airflow_db')\gexec

\i /docker-entrypoint-initdb.d/sql/init_raw_tables.sql
\i /docker-entrypoint-initdb.d/sql/init_analytics_tables.sql
