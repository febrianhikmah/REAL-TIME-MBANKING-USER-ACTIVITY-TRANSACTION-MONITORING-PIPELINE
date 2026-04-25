FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY producers ./producers
COPY consumers ./consumers

ENV PYTHONUNBUFFERED=1
