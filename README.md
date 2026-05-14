# 🚀 REAL-TIME MBANKING USER ACTIVITY & TRANSACTION MONITORING PIPELINE
---

![Pipeline Monitoring](<./Pipeline Monitoring, Real-time MBanking User Activity and Transaction.png>)

## ✨ Gambaran Umum

Proyek ini merupakan implementasi pipeline data engineering end-to-end untuk mensimulasikan, mengalirkan, menyimpan, dan menganalisis aktivitas user pada aplikasi mobile banking secara real-time.

Proyek ini berangkat dari pertanyaan sederhana:

> "Bagaimana cara membangun pipeline real-time untuk memonitor aktivitas user, transaksi, failed login, dan potensi fraud signal pada aplikasi mobile banking?"

Untuk menjawabnya, saya membangun sistem berbasis event-driven architecture menggunakan Kafka sebagai message broker, PostgreSQL sebagai raw dan analytics storage, serta Apache Airflow sebagai orchestrator untuk transformasi data terjadwal.

### Seluruh proses berjalan otomatis menggunakan Docker Compose.

---

## ⚙️ Gambaran Pipeline

Pipeline ini terdiri dari 5 tahap utama:

1. Event Simulation Layer
- Python producer membuat data sintetis aktivitas mobile banking
- Event yang disimulasikan meliputi login, failed login, balance inquiry, transfer, bill payment, QR payment, device change, high-value transaction, dan suspicious activity
- Setiap event memiliki atribut seperti user, account, session, device, lokasi, timestamp, dan metadata risk score

📂 Output:

```text
Synthetic JSON banking events
```

---

2. Kafka Streaming Layer
- Producer mengirim event ke Apache Kafka
- Event dirouting berdasarkan `event_category`
- Setiap domain event masuk ke topic Kafka yang berbeda

📌 Kafka Topics:

- `banking_auth_events`
- `banking_account_events`
- `banking_transaction_events`
- `banking_security_events`

---

3. Raw Ingestion Layer
- Setiap Kafka topic dibaca oleh consumer yang berbeda
- Consumer menyimpan event ke PostgreSQL raw table sesuai domain
- Data raw disimpan dalam bentuk terstruktur, dengan metadata JSON tetap dipertahankan

📊 Raw Tables:

- `raw_auth_events`
- `raw_account_events`
- `raw_transaction_events`
- `raw_security_events`

---

4. Analytics Transformation Layer
- Apache Airflow menjalankan DAG untuk mengolah data raw
- Transformasi dilakukan menggunakan SQL
- Data raw digabung, diagregasi, dan dimodelkan menjadi tabel analytics

📌 Airflow DAGs:

- `daily_active_banking_users`
- `daily_transaction_summary`
- `failed_login_monitoring`
- `suspicious_activity_summary`
- `banking_session_summary`

---

5. Analytics & Monitoring Layer
- Hasil transformasi disimpan kembali ke PostgreSQL analytics tables
- Tabel ini siap digunakan untuk dashboard, reporting, atau analisis fraud signal sederhana

📊 Analytics Tables:

- `daily_active_banking_users`
- `daily_transaction_summary`
- `failed_login_summary_daily`
- `suspicious_activity_summary_daily`
- `banking_session_summary_daily`

---

## 🧰 Teknologi yang Digunakan

| Layer                  | Teknologi                         |
|------------------------|-----------------------------------|
| Event Simulation       | Python                            |
| Message Broker         | Apache Kafka                      |
| Event Routing          | Kafka Producer                    |
| Stream Ingestion       | Python Kafka Consumers            |
| Raw Storage            | PostgreSQL                        |
| Analytics Storage      | PostgreSQL                        |
| Orchestration          | Apache Airflow                    |
| Transformation         | SQL                               |
| Containerization       | Docker & Docker Compose           |

---

## 🗂️ Struktur Proyek

```text
.
├── docker-compose.yml
├── Dockerfile
├── requirements.txt
├── producers/
│   ├── banking_event_producer.py
│   └── event_factory.py
├── consumers/
│   ├── base_consumer.py
│   ├── auth_consumer.py
│   ├── account_consumer.py
│   ├── transaction_consumer.py
│   └── security_consumer.py
├── airflow/
│   ├── Dockerfile
│   └── dags/
│       ├── daily_active_users_dag.py
│       ├── daily_transaction_summary_dag.py
│       ├── failed_login_monitoring_dag.py
│       ├── suspicious_activity_summary_dag.py
│       └── banking_session_summary_dag.py
├── sql/
│   ├── init_raw_tables.sql
│   ├── init_analytics_tables.sql
│   ├── daily_active_users.sql
│   ├── daily_transaction_summary.sql
│   ├── failed_login_summary.sql
│   ├── suspicious_activity_summary.sql
│   └── banking_session_summary.sql
└── postgres/
    └── init.sql
```

---

## 🚀 Cara Menjalankan Project

1. Jalankan seluruh service menggunakan Docker Compose:

```bash
docker compose up -d --build
```

2. Cek container yang berjalan:

```bash
docker compose ps
```

3. Buka Airflow UI:

```text
http://localhost:8080
username: admin
password: admin
```

4. Koneksi PostgreSQL dari pgAdmin:

```text
Host: 127.0.0.1
Port: 5433
Database: banking_activity_db
Username: postgres
Password: postgres
```

5. Jika ingin menghentikan injeksi event sementara:

```bash
docker compose stop producer
```

6. Jika ingin mematikan semua service tanpa menghapus data:

```bash
docker compose down
```

> Jangan gunakan `docker compose down -v` jika ingin data PostgreSQL tetap tersimpan.

---

## 🔎 Cara Kerja Sistem

- Python producer membuat event dummy mobile banking secara terus-menerus
- Producer menentukan Kafka topic berdasarkan `event_category`
- Kafka menyimpan event berdasarkan domain: auth, account, transaction, dan security
- Empat consumer membaca topic masing-masing secara real-time
- Consumer menyimpan data ke raw table PostgreSQL
- Airflow menjalankan SQL DAG untuk membuat analytics table
- Analytics table digunakan untuk monitoring user activity, transaksi, failed login, dan suspicious activity

---

## 📊 Hasil Output

Pipeline menghasilkan dua jenis output utama:

1. Raw Layer
- Data event tersimpan berdasarkan domain
- Setiap tabel raw merepresentasikan satu kategori aktivitas banking
- Metadata event tetap disimpan dalam kolom JSONB

2. Analytics Layer
- Daily active banking users
- Daily transaction summary
- Failed login risk monitoring
- Suspicious activity summary
- Banking session summary

Data siap digunakan untuk:

- Dashboard monitoring aktivitas mobile banking
- Analisis transaksi harian
- Monitoring failed login
- Identifikasi user berisiko
- Analisis pola session user
- Fraud signal engineering sederhana

---

## 💡 Insight & Nilai Proyek

- Membangun real-time data ingestion menggunakan Kafka
- Menerapkan multi-topic Kafka design berdasarkan domain event
- Membuat multi-consumer ingestion pipeline
- Mendesain raw layer dan analytics layer di PostgreSQL
- Menggunakan Airflow untuk orkestrasi transformasi data
- Membuat SQL transformation untuk monitoring user, transaksi, login risk, dan suspicious activity
- Menjalankan seluruh stack secara containerized menggunakan Docker Compose
- Mensimulasikan arsitektur event-driven yang dekat dengan use case industri banking

---

## 🔐 Catatan Data Privacy

Project ini hanya menggunakan data sintetis atau dummy data.

Data yang tidak boleh digunakan:

- Nama asli nasabah
- Nomor rekening asli
- Nomor kartu
- PIN
- OTP
- Password
- Nomor identitas resmi
- Alamat rumah asli

Contoh ID dummy yang digunakan:

- `user_1001`
- `acct_1001`
- `trx_928812`
- `device_8821`
- `merchant_5521`

---

## 🏁 Kesimpulan

Proyek ini mensimulasikan bagaimana seorang data engineer membangun pipeline real-time untuk monitoring aktivitas mobile banking dari event generation hingga analytics table.

Melalui proyek ini, saya memahami pentingnya:

- Desain event-driven architecture
- Pemisahan Kafka topic berdasarkan domain event
- Penyimpanan raw data untuk kebutuhan audit dan reprocessing
- Transformasi data terjadwal menggunakan Airflow
- Pembuatan analytics table untuk kebutuhan monitoring dan reporting
- Penggunaan Docker Compose untuk membuat environment project yang reproducible
