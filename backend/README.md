# VYTRA study API

Optional. The Android app screens and writes PDFs with no network.

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
uvicorn app.main:app --host 0.0.0.0 --port 8000
# GET http://127.0.0.1:8000/api/v1/health
```

`device_id` on stored rows comes from `JWT.sub`. The sync JSON must not include it.

Postgres DDL is in `schema.sql` for a later study host. Local and compose use SQLite so `docker compose up` does not publish a database port.
