from __future__ import annotations

import os
import tempfile
import unittest
from pathlib import Path
from uuid import uuid4

os.environ.setdefault("JWT_SECRET", "test-secret")
os.environ.setdefault("ADMIN_KEY", "test-admin")
os.environ.setdefault("ORG_CODES", "ASHA-HYD-04,DEMO")
os.environ["VYTRA_DB"] = str(Path(tempfile.gettempdir()) / f"vytra-test-{uuid4().hex}.db")

from fastapi.testclient import TestClient

from app.main import app  # noqa: E402

DEVICE = "550e8400-e29b-41d4-a716-446655440000"
SCREEN = "11111111-1111-4111-8111-111111111111"
CAPTURE = "22222222-2222-4222-8222-222222222222"


def screening(**over):
    base = {
        "screening_id": SCREEN,
        "captured_at": "2026-08-13T06:00:00Z",
        "anemia_risk": "MODERATE",
        "jaundice_risk": "LOW",
        "anemia_a_star": 8.0,
        "jaundice_b_star": 4.0,
        "valid_anemia_count": 2,
        "valid_jaundice_count": 2,
        "algorithm_version": "alg-1.1.0",
        "threshold_version": "th-1.0.0",
        "app_version": "1.0.0",
        "consent_recorded_at": "2026-08-13T05:59:00Z",
        "ambient_lighting": "INDOOR_NATURAL",
        "fitzpatrick_scale": 4,
        "fitzpatrick_assessment_method": "WORKER_ASSESSED",
    }
    base.update(over)
    return base


class ApiTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.client = TestClient(app)

    def test_health(self) -> None:
        r = self.client.get("/api/v1/health")
        self.assertEqual(r.status_code, 200)
        self.assertTrue(r.json()["ok"])
        self.assertTrue(r.json()["ts"].endswith("Z"))

    def test_register_rejects_unknown_org(self) -> None:
        r = self.client.post(
            "/api/v1/devices/register",
            json={"device_id": DEVICE, "org_code": "NOPE"},
        )
        self.assertEqual(r.status_code, 403)

    def test_sync_round_trip_and_local_wins(self) -> None:
        r = self.client.post(
            "/api/v1/devices/register",
            json={"device_id": DEVICE, "org_code": "ASHA-HYD-04", "app_version": "1.0.0"},
        )
        self.assertEqual(r.status_code, 201)
        token = r.json()["access_token"]
        headers = {"Authorization": f"Bearer {token}"}

        r = self.client.post(
            "/api/v1/sync",
            headers=headers,
            json={
                "screenings": [screening()],
                "captures": [
                    {
                        "capture_id": CAPTURE,
                        "screening_id": SCREEN,
                        "series": "ANEMIA",
                        "capture_index": 1,
                        "valid": 1,
                        "mesh_used": 0,
                        "captured_at": "2026-08-13T06:00:00Z",
                    }
                ],
            },
        )
        self.assertEqual(r.status_code, 200, r.text)
        self.assertEqual(r.json()["accepted_screening_ids"], [SCREEN])

        r = self.client.post(
            "/api/v1/sync",
            headers=headers,
            json={"screenings": [screening(anemia_risk="HIGH")], "captures": []},
        )
        self.assertEqual(r.status_code, 200)

        # identity fields are rejected
        r = self.client.post(
            "/api/v1/sync",
            headers=headers,
            json={"screenings": [screening(patient_name="x")], "captures": []},
        )
        self.assertEqual(r.status_code, 400)

    def test_sync_requires_token(self) -> None:
        r = self.client.post("/api/v1/sync", json={"screenings": [], "captures": []})
        self.assertEqual(r.status_code, 401)

    def test_revoke(self) -> None:
        r = self.client.post(
            "/api/v1/devices/register",
            json={"device_id": "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa", "org_code": "DEMO"},
        )
        token = r.json()["access_token"]
        r = self.client.post(
            "/api/v1/devices/revoke",
            headers={"X-Admin-Key": "test-admin"},
            json={"device_id": "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa"},
        )
        self.assertEqual(r.status_code, 200)
        r = self.client.post(
            "/api/v1/sync",
            headers={"Authorization": f"Bearer {token}"},
            json={"screenings": [], "captures": []},
        )
        self.assertEqual(r.status_code, 401)


if __name__ == "__main__":
    unittest.main()
