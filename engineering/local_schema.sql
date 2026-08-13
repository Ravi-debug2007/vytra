-- Local SQLCipher schema. No device_id. No patients table. Hard DELETE on retention.

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
