"""VYTRA study API. Four routes. SQLite by default so `uvicorn` works without Postgres."""

from __future__ import annotations

import os
import sqlite3
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Any

import jwt
from fastapi import FastAPI, Header, HTTPException, Request
from fastapi.responses import JSONResponse
from pydantic import BaseModel, ConfigDict, Field

FORBIDDEN_BODY_KEYS = {"patient_name", "patient_ref", "photo_path", "latitude", "longitude"}
RISKS = {"LOW", "MODERATE", "HIGH", "UNABLE_TO_ASSESS"}
LIGHTING = {"INDOOR_NATURAL", "INDOOR_ARTIFICIAL", "OUTDOOR_SHADE", "OUTDOOR_DIRECT"}
METHODS = {"SELF_REPORTED", "WORKER_ASSESSED"}
SERIES = {"ANEMIA", "JAUNDICE"}
REASONS = {
    "BLUR",
    "EXPOSURE_DARK",
    "EXPOSURE_BRIGHT",
    "EYE_CLOSED",
    "ROI_TOO_SMALL",
    "WHITE_REF_FAIL",
    "MESH_MISSING",
    "OTHER",
}


def _env(name: str, default: str) -> str:
    return os.environ.get(name, default)


JWT_SECRET = _env("JWT_SECRET", "dev-only-not-for-study")
ADMIN_KEY = _env("ADMIN_KEY", "dev-admin-not-for-study")
ORG_CODES = {c.strip() for c in _env("ORG_CODES", "ASHA-HYD-04,DEMO").split(",") if c.strip()}
DB_PATH = Path(_env("VYTRA_DB", str(Path(__file__).resolve().parents[1] / "data" / "vytra.db")))


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


def iso(dt: datetime) -> str:
    return dt.astimezone(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def connect() -> sqlite3.Connection:
    DB_PATH.parent.mkdir(parents=True, exist_ok=True)
    con = sqlite3.connect(DB_PATH)
    con.row_factory = sqlite3.Row
    con.execute("PRAGMA foreign_keys = ON")
    return con


def init_db() -> None:
    con = connect()
    con.executescript(
        """
        CREATE TABLE IF NOT EXISTS devices (
            device_id TEXT PRIMARY KEY,
            org_code TEXT NOT NULL,
            app_version TEXT,
            registered_at TEXT NOT NULL,
            revoked_at TEXT
        );
        CREATE TABLE IF NOT EXISTS screenings (
            screening_id TEXT PRIMARY KEY,
            device_id TEXT NOT NULL,
            captured_at TEXT NOT NULL,
            anemia_risk TEXT NOT NULL,
            jaundice_risk TEXT NOT NULL,
            anemia_a_star REAL,
            jaundice_b_star REAL,
            valid_anemia_count INTEGER NOT NULL DEFAULT 0,
            valid_jaundice_count INTEGER NOT NULL DEFAULT 0,
            final_quality_score REAL,
            algorithm_version TEXT NOT NULL,
            threshold_version TEXT NOT NULL,
            app_version TEXT NOT NULL,
            device_model TEXT,
            fitzpatrick_scale INTEGER,
            fitzpatrick_assessment_method TEXT,
            ambient_lighting TEXT,
            consent_recorded_at TEXT NOT NULL,
            synced_at TEXT
        );
        CREATE TABLE IF NOT EXISTS captures (
            capture_id TEXT PRIMARY KEY,
            screening_id TEXT NOT NULL,
            series TEXT NOT NULL,
            capture_index INTEGER NOT NULL,
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
        """
    )
    con.commit()
    con.close()


class RegisterRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")
    device_id: str
    org_code: str
    app_version: str | None = None


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    expires_at: str


class RevokeRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")
    device_id: str


class ScreeningIn(BaseModel):
    model_config = ConfigDict(extra="forbid")
    screening_id: str
    captured_at: str
    anemia_risk: str
    jaundice_risk: str
    anemia_a_star: float | None = None
    jaundice_b_star: float | None = None
    valid_anemia_count: int
    valid_jaundice_count: int
    final_quality_score: float | None = None
    algorithm_version: str
    threshold_version: str
    app_version: str
    device_model: str | None = None
    fitzpatrick_scale: int | None = None
    fitzpatrick_assessment_method: str | None = None
    ambient_lighting: str | None = None
    consent_recorded_at: str


class CaptureIn(BaseModel):
    model_config = ConfigDict(extra="forbid")
    capture_id: str
    screening_id: str
    series: str
    capture_index: int
    blur_score: float | None = None
    exposure_score: float | None = None
    eye_openness_score: float | None = None
    roi_quality_score: float | None = None
    white_reference_score: float | None = None
    anemia_a_star: float | None = None
    jaundice_b_star: float | None = None
    l_star: float | None = None
    valid: int
    rejection_reason: str | None = None
    mesh_used: int = 0
    captured_at: str


class SyncRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")
    screenings: list[ScreeningIn] = Field(default_factory=list)
    captures: list[CaptureIn] = Field(default_factory=list)


app = FastAPI(title="VYTRA study API", version="1.0.0", docs_url=None, redoc_url=None)
init_db()


@app.middleware("http")
async def reject_identity_keys(request: Request, call_next):
    if request.method in {"POST", "PUT", "PATCH"}:
        raw = await request.body()
        if raw:
            text = raw.decode("utf-8", errors="replace")
            for key in FORBIDDEN_BODY_KEYS:
                if f'"{key}"' in text:
                    return JSONResponse({"detail": f"forbidden field {key}"}, status_code=400)

        async def receive() -> dict[str, Any]:
            return {"type": "http.request", "body": raw, "more_body": False}

        request = Request(request.scope, receive)
    return await call_next(request)


def issue_token(device_id: str, org_code: str) -> TokenResponse:
    exp = utc_now() + timedelta(days=30)
    token = jwt.encode(
        {"sub": device_id, "org": org_code, "exp": exp},
        JWT_SECRET,
        algorithm="HS256",
    )
    return TokenResponse(access_token=token, expires_at=iso(exp))


def read_token(authorization: str | None) -> dict:
    if not authorization or not authorization.lower().startswith("bearer "):
        raise HTTPException(status_code=401, detail="missing token")
    token = authorization.split(" ", 1)[1].strip()
    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=["HS256"])
    except jwt.PyJWTError as exc:
        raise HTTPException(status_code=401, detail="invalid token") from exc
    device_id = payload.get("sub")
    if not device_id:
        raise HTTPException(status_code=401, detail="invalid token")
    con = connect()
    row = con.execute("SELECT revoked_at FROM devices WHERE device_id = ?", (device_id,)).fetchone()
    con.close()
    if row is None or row["revoked_at"]:
        raise HTTPException(status_code=401, detail="revoked")
    return payload


@app.get("/api/v1/health")
def health() -> dict:
    return {"ok": True, "ts": iso(utc_now())}


@app.post("/api/v1/devices/register", status_code=201)
def register(body: RegisterRequest) -> TokenResponse:
    if body.org_code not in ORG_CODES:
        raise HTTPException(status_code=403, detail="org_code not allowed")
    now = iso(utc_now())
    con = connect()
    con.execute(
        """
        INSERT INTO devices(device_id, org_code, app_version, registered_at, revoked_at)
        VALUES (?, ?, ?, ?, NULL)
        ON CONFLICT(device_id) DO UPDATE SET
            org_code = excluded.org_code,
            app_version = excluded.app_version,
            registered_at = excluded.registered_at,
            revoked_at = NULL
        """,
        (body.device_id, body.org_code, body.app_version, now),
    )
    con.commit()
    con.close()
    return issue_token(body.device_id, body.org_code)


@app.post("/api/v1/sync")
def sync(body: SyncRequest, authorization: str | None = Header(default=None)) -> dict:
    claims = read_token(authorization)
    device_id = claims["sub"]
    if len(body.screenings) > 100:
        raise HTTPException(status_code=413, detail="batch too large")

    rejected: list[dict[str, str]] = []
    accepted: list[str] = []
    con = connect()
    try:
        for s in body.screenings:
            if s.anemia_risk not in RISKS or s.jaundice_risk not in RISKS:
                rejected.append({"id": s.screening_id, "reason": "bad risk"})
                continue
            if s.ambient_lighting and s.ambient_lighting not in LIGHTING:
                rejected.append({"id": s.screening_id, "reason": "bad lighting"})
                continue
            if s.fitzpatrick_assessment_method and s.fitzpatrick_assessment_method not in METHODS:
                rejected.append({"id": s.screening_id, "reason": "bad method"})
                continue
            con.execute(
                """
                INSERT INTO screenings(
                    screening_id, device_id, captured_at, anemia_risk, jaundice_risk,
                    anemia_a_star, jaundice_b_star, valid_anemia_count, valid_jaundice_count,
                    final_quality_score, algorithm_version, threshold_version, app_version,
                    device_model, fitzpatrick_scale, fitzpatrick_assessment_method,
                    ambient_lighting, consent_recorded_at, synced_at
                ) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
                ON CONFLICT(screening_id) DO UPDATE SET
                    device_id = excluded.device_id,
                    captured_at = excluded.captured_at,
                    anemia_risk = excluded.anemia_risk,
                    jaundice_risk = excluded.jaundice_risk,
                    anemia_a_star = excluded.anemia_a_star,
                    jaundice_b_star = excluded.jaundice_b_star,
                    valid_anemia_count = excluded.valid_anemia_count,
                    valid_jaundice_count = excluded.valid_jaundice_count,
                    final_quality_score = excluded.final_quality_score,
                    algorithm_version = excluded.algorithm_version,
                    threshold_version = excluded.threshold_version,
                    app_version = excluded.app_version,
                    device_model = excluded.device_model,
                    fitzpatrick_scale = excluded.fitzpatrick_scale,
                    fitzpatrick_assessment_method = excluded.fitzpatrick_assessment_method,
                    ambient_lighting = excluded.ambient_lighting,
                    consent_recorded_at = excluded.consent_recorded_at,
                    synced_at = excluded.synced_at
                """,
                (
                    s.screening_id,
                    device_id,
                    s.captured_at,
                    s.anemia_risk,
                    s.jaundice_risk,
                    s.anemia_a_star,
                    s.jaundice_b_star,
                    s.valid_anemia_count,
                    s.valid_jaundice_count,
                    s.final_quality_score,
                    s.algorithm_version,
                    s.threshold_version,
                    s.app_version,
                    s.device_model,
                    s.fitzpatrick_scale,
                    s.fitzpatrick_assessment_method,
                    s.ambient_lighting,
                    s.consent_recorded_at,
                    iso(utc_now()),
                ),
            )
            accepted.append(s.screening_id)

        for c in body.captures:
            if c.series not in SERIES or c.capture_index not in (1, 2, 3) or c.valid not in (0, 1):
                rejected.append({"id": c.capture_id, "reason": "bad capture"})
                continue
            if c.rejection_reason and c.rejection_reason not in REASONS:
                rejected.append({"id": c.capture_id, "reason": "bad reason"})
                continue
            exists = con.execute(
                "SELECT 1 FROM screenings WHERE screening_id = ?", (c.screening_id,)
            ).fetchone()
            if exists is None:
                rejected.append({"id": c.capture_id, "reason": "unknown screening"})
                continue
            con.execute(
                """
                INSERT INTO captures(
                    capture_id, screening_id, series, capture_index, blur_score, exposure_score,
                    eye_openness_score, roi_quality_score, white_reference_score,
                    anemia_a_star, jaundice_b_star, l_star, valid, rejection_reason,
                    mesh_used, captured_at
                ) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
                ON CONFLICT(capture_id) DO UPDATE SET
                    series = excluded.series,
                    capture_index = excluded.capture_index,
                    blur_score = excluded.blur_score,
                    exposure_score = excluded.exposure_score,
                    eye_openness_score = excluded.eye_openness_score,
                    roi_quality_score = excluded.roi_quality_score,
                    white_reference_score = excluded.white_reference_score,
                    anemia_a_star = excluded.anemia_a_star,
                    jaundice_b_star = excluded.jaundice_b_star,
                    l_star = excluded.l_star,
                    valid = excluded.valid,
                    rejection_reason = excluded.rejection_reason,
                    mesh_used = excluded.mesh_used,
                    captured_at = excluded.captured_at
                """,
                (
                    c.capture_id,
                    c.screening_id,
                    c.series,
                    c.capture_index,
                    c.blur_score,
                    c.exposure_score,
                    c.eye_openness_score,
                    c.roi_quality_score,
                    c.white_reference_score,
                    c.anemia_a_star,
                    c.jaundice_b_star,
                    c.l_star,
                    c.valid,
                    c.rejection_reason,
                    c.mesh_used,
                    c.captured_at,
                ),
            )
        con.commit()
    finally:
        con.close()
    return {"accepted_screening_ids": accepted, "rejected": rejected}


@app.post("/api/v1/devices/revoke")
def revoke(body: RevokeRequest, x_admin_key: str | None = Header(default=None)) -> dict:
    if x_admin_key != ADMIN_KEY:
        raise HTTPException(status_code=401, detail="bad admin key")
    con = connect()
    con.execute(
        "UPDATE devices SET revoked_at = ? WHERE device_id = ?",
        (iso(utc_now()), body.device_id),
    )
    con.commit()
    con.close()
    return {"ok": True, "device_id": body.device_id}
