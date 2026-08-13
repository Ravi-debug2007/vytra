-- VYTRA study server — PostgreSQL 16
-- device_id on screenings is taken from JWT.sub, never from the JSON body.

CREATE TABLE IF NOT EXISTS devices (
    device_id     TEXT PRIMARY KEY,
    org_code      TEXT NOT NULL,
    app_version   TEXT,
    registered_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    revoked_at    TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS screenings (
    screening_id                   TEXT PRIMARY KEY,
    device_id                      TEXT NOT NULL REFERENCES devices(device_id),
    captured_at                    TEXT NOT NULL,
    anemia_risk                    TEXT NOT NULL CHECK (anemia_risk IN
                                   ('LOW','MODERATE','HIGH','UNABLE_TO_ASSESS')),
    jaundice_risk                  TEXT NOT NULL CHECK (jaundice_risk IN
                                   ('LOW','MODERATE','HIGH','UNABLE_TO_ASSESS')),
    anemia_a_star                  DOUBLE PRECISION,
    jaundice_b_star                DOUBLE PRECISION,
    valid_anemia_count             INTEGER NOT NULL DEFAULT 0,
    valid_jaundice_count           INTEGER NOT NULL DEFAULT 0,
    final_quality_score            DOUBLE PRECISION,
    algorithm_version              TEXT NOT NULL,
    threshold_version              TEXT NOT NULL,
    app_version                    TEXT NOT NULL,
    device_model                   TEXT,
    fitzpatrick_scale              INTEGER CHECK (fitzpatrick_scale BETWEEN 1 AND 6),
    fitzpatrick_assessment_method  TEXT CHECK
                                   (fitzpatrick_assessment_method IN ('SELF_REPORTED','WORKER_ASSESSED')),
    ambient_lighting               TEXT CHECK (ambient_lighting IN
                                   ('INDOOR_NATURAL','INDOOR_ARTIFICIAL','OUTDOOR_SHADE','OUTDOOR_DIRECT')),
    consent_recorded_at            TEXT NOT NULL,
    synced_at                      TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS captures (
    capture_id             TEXT PRIMARY KEY,
    screening_id           TEXT NOT NULL REFERENCES screenings(screening_id) ON DELETE CASCADE,
    series                 TEXT NOT NULL CHECK (series IN ('ANEMIA','JAUNDICE')),
    capture_index          INTEGER NOT NULL CHECK (capture_index BETWEEN 1 AND 3),
    blur_score             DOUBLE PRECISION,
    exposure_score         DOUBLE PRECISION,
    eye_openness_score     DOUBLE PRECISION,
    roi_quality_score      DOUBLE PRECISION,
    white_reference_score  DOUBLE PRECISION,
    anemia_a_star          DOUBLE PRECISION,
    jaundice_b_star        DOUBLE PRECISION,
    l_star                 DOUBLE PRECISION,
    valid                  INTEGER NOT NULL DEFAULT 0,
    rejection_reason       TEXT,
    mesh_used              INTEGER NOT NULL DEFAULT 0,
    captured_at            TEXT NOT NULL,
    UNIQUE (screening_id, series, capture_index)
);

CREATE INDEX IF NOT EXISTS idx_screenings_device ON screenings(device_id);
CREATE INDEX IF NOT EXISTS idx_screenings_captured_at ON screenings(captured_at);
CREATE INDEX IF NOT EXISTS idx_captures_screening ON captures(screening_id);
