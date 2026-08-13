# 06 — Data Model and API

Authoritative schemas. If Dart models, SQL, and OpenAPI drift, this file plus the machine-readable copies win.

Machine-readable:

- [`backend/schema.sql`](backend/schema.sql)
- [`backend/openapi.yaml`](backend/openapi.yaml)
- [`backend/docker-compose.yml`](backend/docker-compose.yml)

---

## 1. Identifiers and clocks

| Field | Rule |
|---|---|
| `screening_id` | UUID v4, generated at consent-agree, **before** any camera use |
| `capture_id` | UUID v4 |
| `device_id` | UUID v4, generated once on first launch, stored in secure storage |
| Timestamps | ISO-8601 **UTC** (`2026-08-12T13:10:00Z`). Convert from device local at write time. Never store a local offset. |
| `app_version` | `package_info_plus` version |
| `algorithm_version` | `alg-1.1.0` |
| `threshold_version` | `th-1.0.0` |

---

## 2. Local SQLite (SQLCipher)

Core: two tables (`screenings`, `captures`). No patients table. If `SECONDARY_TOOLS=true`, also create `secondary_scans` from `11_SECONDARY_MODULES.md`. Never add identity columns.

```sql
CREATE TABLE screenings (
    screening_id TEXT PRIMARY KEY,
    captured_at TEXT NOT NULL,
    anemia_risk TEXT NOT NULL CHECK (anemia_risk IN
        ('LOW','MODERATE','HIGH','UNABLE_TO_ASSESS')),
    jaundice_risk TEXT NOT NULL CHECK (jaundice_risk IN
        ('LOW','MODERATE','HIGH','UNABLE_TO_ASSESS')),
    anemia_a_star REAL,
    jaundice_b_star REAL,
    valid_anemia_count INTEGER NOT NULL DEFAULT 0,
    valid_jaundice_count INTEGER NOT NULL DEFAULT 0,
    final_quality_score REAL,
    algorithm_version TEXT NOT NULL,
    threshold_version TEXT NOT NULL,
    app_version TEXT NOT NULL,
    device_model TEXT,
    fitzpatrick_scale INTEGER CHECK (fitzpatrick_scale BETWEEN 1 AND 6),
    fitzpatrick_assessment_method TEXT CHECK
        (fitzpatrick_assessment_method IN ('SELF_REPORTED','WORKER_ASSESSED')),
    ambient_lighting TEXT CHECK (ambient_lighting IN
        ('INDOOR_NATURAL','INDOOR_ARTIFICIAL','OUTDOOR_SHADE','OUTDOOR_DIRECT')),
    sync_status TEXT NOT NULL DEFAULT 'PENDING' CHECK
        (sync_status IN ('PENDING','SYNCED','FAILED')),
    consent_recorded_at TEXT NOT NULL
);

CREATE TABLE captures (
    capture_id TEXT PRIMARY KEY,
    screening_id TEXT NOT NULL REFERENCES screenings(screening_id) ON DELETE CASCADE,
    series TEXT NOT NULL CHECK (series IN ('ANEMIA','JAUNDICE')),
    capture_index INTEGER NOT NULL CHECK (capture_index BETWEEN 1 AND 3),
    blur_score REAL,
    exposure_score REAL,
    eye_openness_score REAL,
    roi_quality_score REAL,
    white_reference_score REAL,
    anemia_a_star REAL,
    jaundice_b_star REAL,
    l_star REAL,
    valid INTEGER NOT NULL DEFAULT 0,
    rejection_reason TEXT,
    mesh_used INTEGER NOT NULL DEFAULT 0,
    captured_at TEXT NOT NULL,
    UNIQUE (screening_id, series, capture_index)
);

CREATE INDEX idx_screenings_captured_at ON screenings(captured_at);
CREATE INDEX idx_screenings_sync ON screenings(sync_status);
CREATE INDEX idx_captures_screening ON captures(screening_id);
```

### 2.1 Column notes

| Column | Rule |
|---|---|
| `anemia_a_star` / `jaundice_b_star` on `screenings` | Median of valid captures, or NULL if `UNABLE_TO_ASSESS` |
| `valid_*_count` | Integer 0–3 |
| `deleted_at` | **Do not use.** Eligibility is computed from UTC `captured_at`. The retention worker issues `DELETE`. Do not add soft-delete logic. |
| `capture_index` | Attempt number `1..3` for that series, **including invalid** attempts. Reusing an index violates UNIQUE. |
| `rejection_reason` | `BLUR` `EXPOSURE_DARK` `EXPOSURE_BRIGHT` `EYE_CLOSED` `ROI_TOO_SMALL` `WHITE_REF_FAIL` `MESH_MISSING` `OTHER` or NULL if valid |
| `mesh_used` | 1 if Face Mesh contributed to the ROI, 0 if ellipse-only |
| `device_model` | `android.os.Build.MODEL`, no user input |

### 2.2 Forbidden columns

`patient_name`, `patient_ref`, `photo_path`, `latitude`, `longitude`, `asha_id`, `phone`, `abha`, `notes`.

A pull request that adds any of these is rejected.

### 2.3 Encryption

```
dbKey = 32 random bytes, created once, stored via flutter_secure_storage
        (Android encryptedSharedPreferences: true)
openDatabase(path, password: hex(dbKey), ...)
path = join(await getDatabasesPath(), 'vytra.db')
```

Never log the key. Never put the DB on external storage.

---

## 3. What is never on disk

- JPEG / PNG of the eye or the white reference
- PDF after share (write to cache, then delete on next launch if older than 24 h)
- Patient reference string

---

## 4. Retention worker

- Unique name `retention_worker`
- Period 6 hours, `NetworkType.notRequired`
- SQL (bound parameter, UTC):  
  `DELETE FROM screenings WHERE captured_at < ?;`  
  bind `cutoff` = current UTC minus 30 days, formatted `YYYY-MM-DDTHH:MM:SSZ`.  
  Cascades to `captures`. Do not use `substr` and do not mix local offsets with `datetime('now')`.
- No deletion log table
- UI and consent: “eligible after 30 days, removed the next time the app cleans up”

---

## 5. HTTP API

Base path `/api/v1`. JSON only. TLS required. Cleartext disabled on the client.

### 5.1 `POST /api/v1/devices/register`

Unauthenticated. Rate-limit 10/min/IP.

Request:

```json
{
  "device_id": "550e8400-e29b-41d4-a716-446655440000",
  "org_code": "ASHA-HYD-04",
  "app_version": "1.0.0"
}
```

`org_code` must be in the server allow-list. Else `403`.

Response `201`:

```json
{
  "access_token": "<jwt>",
  "token_type": "bearer",
  "expires_at": "2026-09-11T12:00:00+00:00"
}
```

JWT claims: `sub = device_id`, `org = org_code`, `exp` ≈ 30 days. Signed with `JWT_SECRET` on the server. HS256 is enough for the study.

**`device_id` is not a field on the sync JSON.** The server sets `screenings.device_id` from `JWT.sub` on every accepted row.

Re-register of the same `device_id` + valid `org_code` issues a new token and invalidates the previous one.

### 5.2 `POST /api/v1/sync`

Header: `Authorization: Bearer <access_token>`

Request:

```json
{
  "screenings": [ { "...screening row without sync_status..." } ],
  "captures":  [ { "...capture rows..." } ]
}
```

Server upserts by primary key. Local field values overwrite. Sets server `synced_at`.

Response `200`:

```json
{
  "accepted_screening_ids": ["..."],
  "rejected": []
}
```

Errors: `401` missing/expired/revoked token, `413` if more than 100 screenings in one call (client must batch).

### 5.3 `POST /api/v1/devices/revoke` (admin)

Header: `X-Admin-Key: <ADMIN_KEY>` (server env, never in the app).

```json
{ "device_id": "..." }
```

Sets `revoked_at`. Next sync is `401`.

### 5.4 `GET /api/v1/health`

```json
{ "ok": true, "ts": "..." }
```

No auth.

---

## 6. Conflict and identity

- Primary key is `screening_id` generated on device. The server never assigns it.
- Local wins, always.
- There is no merge UI.

---

## 7. Server schema extras

Postgres adds:

```sql
CREATE TABLE devices (
    device_id TEXT PRIMARY KEY,
    org_code TEXT NOT NULL,
    app_version TEXT,
    registered_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    revoked_at TIMESTAMPTZ
);

ALTER TABLE screenings ADD COLUMN synced_at TIMESTAMPTZ;
```

No patient table. No file store.

---

## 8. Client sync behaviour

```
on connectivity restored OR app start OR S10 pull:
    token missing → if network, register, else wait
    POST /sync with all rows where sync_status != SYNCED
    on 200 → those ids become SYNCED
    on 401 → clear token, try register once, then FAILED
    on other → FAILED, backoff 5,10,20,40,60 s (cap)
    after 10 failures this process lifetime → stop until next app start
```

Worker: `sync_worker`, 6 h, `NetworkType.connected`.

---

## 9. Environment

| Variable | Where | Example |
|---|---|---|
| `ORG_CODE` | Flutter `--dart-define` | `ASHA-HYD-04` |
| `API_BASE_URL` | Flutter `--dart-define` | `https://vytra.example.org` |
| `RESEARCH_PIN` | Flutter `--dart-define` | per-build secret; never the documented example |
| `DEBUG_LAB` | Flutter `--dart-define` | `false` |
| `SECONDARY_TOOLS` | Flutter `--dart-define` | `false` (default). Do not enable until models are live. |
| `DATABASE_URL` | FastAPI | `postgresql+asyncpg://...` |
| `JWT_SECRET` | FastAPI | 32+ random bytes |
| `ADMIN_KEY` | FastAPI | random |
| `ORG_CODES` | FastAPI | `ASHA-HYD-04,ASHA-HYD-05` |

Demo flavour may set `API_BASE_URL` empty. Sync becomes a no-op that leaves rows `PENDING` without error.

---

## 10. Mapping PRD names that died

| Old name (retired docs) | Now |
|---|---|
| `quality_gate_result` JSON blob | typed columns on `captures` |
| `quality_override` | removed (override cut) |
| `valid_capture_count` | split into `valid_anemia_count` + `valid_jaundice_count` |
| `X-API-Key` | Bearer token |
| `X-Signature` / device keypair | removed |
| `MIXED` lighting | removed |
| `OUTDOOR` lighting | split into `OUTDOOR_SHADE` and `OUTDOOR_DIRECT` |
