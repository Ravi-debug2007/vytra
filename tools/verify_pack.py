#!/usr/bin/env python3
"""Go/no-go for the VYTRA vibe-coding pack. Exit 0 only if every check passes."""

from __future__ import annotations

import json
import os
import re
import sys
import tempfile
import traceback
import unittest
from pathlib import Path
from uuid import uuid4

ROOT = Path(__file__).resolve().parents[1]
FAILS: list[str] = []
OKS: list[str] = []


def ok(msg: str) -> None:
    OKS.append(msg)
    print(f"  ok   {msg}")


def fail(msg: str) -> None:
    FAILS.append(msg)
    print(f"  FAIL {msg}")


def check_files() -> None:
    required = [
        "README.md",
        "AGENT_PROMPT.md",
        "00_DOCUMENT_CONTROL.md",
        "01_PRODUCT_LOCK.md",
        "02_VIBE_SPEC.md",
        "03_SCREENS_AND_STATES.md",
        "04_DESIGN_SYSTEM.md",
        "05_VISION_PIPELINE.md",
        "06_DATA_AND_API.md",
        "07_LOCALIZATION.md",
        "08_ENGINEERING_BOOTSTRAP.md",
        "09_CONSENT_AND_SAFETY.md",
        "10_ACCEPTANCE_TESTS.md",
        "11_SECONDARY_MODULES.md",
        "engineering/pubspec.yaml",
        "engineering/l10n.yaml",
        "engineering/local_schema.sql",
        "l10n/app_en.arb",
        "l10n/app_te.arb",
        "l10n/app_hi.arb",
        "legal/consent_form_hi.md",
        "vision/cielab_reference.py",
        "vision/classify.py",
        "vision/golden_cielab.json",
        "backend/openapi.yaml",
        "backend/schema.sql",
        "backend/app/main.py",
        "backend/docker-compose.yml",
        "design/BRAND.md",
        "design/vytra_mark.png",
        "design/vytra_logo_lockup.png",
        "legal/consent_form_en.md",
        "legal/consent_form_te.md",
        "reference/lib/src/vision/cielab.dart",
        "reference/lib/src/vision/classify.dart",
        "assets/icons/icon_risk_high.svg",
        "assets/icons/icon_risk_moderate.svg",
        "assets/icons/icon_risk_low.svg",
        "assets/icons/icon_risk_unable.svg",
        "assets/icons/icon_new_screening.svg",
        "assets/icons/icon_lid.svg",
        "assets/icons/icon_sclera.svg",
        "assets/icons/icon_paper.svg",
        "assets/icons/icon_pdf.svg",
        "assets/icons/icon_lamp_ok.svg",
        "assets/icons/icon_lamp_bad.svg",
    ]
    for rel in required:
        if (ROOT / rel).is_file():
            ok(f"exists {rel}")
        else:
            fail(f"missing {rel}")


def arb_user_keys(path: Path) -> dict[str, str]:
    data = json.loads(path.read_text(encoding="utf-8"))
    return {k: v for k, v in data.items() if not k.startswith("@") and k != "@@locale"}


def check_arb() -> None:
    en = arb_user_keys(ROOT / "l10n/app_en.arb")
    te = arb_user_keys(ROOT / "l10n/app_te.arb")
    hi = arb_user_keys(ROOT / "l10n/app_hi.arb")
    if set(en) == set(te) == set(hi):
        ok(f"ARB key parity en/te/hi ({len(en)} keys)")
    else:
        fail(f"ARB key mismatch {sorted(set(en) ^ set(te) ^ set(hi))[:12]}")

    ident = re.compile(r"^[a-z][A-Za-z0-9]*$")
    dotted = [k for k in en if not ident.match(k)]
    if dotted:
        fail(f"ARB keys not camelCase identifiers: {dotted}")
    else:
        ok("ARB keys are camelCase Dart identifiers")

    locked = {
        "disclaimerFull": (
            "This screening result is not a medical diagnosis. "
            "It is a triage aid for trained health workers only. "
            "All results require confirmation by a qualified medical professional. "
            "Do not make treatment decisions based on this result alone."
        ),
        "actionAnemiaHigh": "Refer to the PHC for a blood test today.",
        "bannerReferToday": "Immediate referral recommended. Accompany the person to the PHC today.",
    }
    for key, text in locked.items():
        if en.get(key) == text:
            ok(f"locked EN {key}")
        else:
            fail(f"locked EN drift: {key}")

    te_disc = (
        "ఈ స్క్రీనింగ్ ఫలితం వైద్య నిర్ధారణ కాదు. "
        "ఇది శిక్షణ పొందిన ఆరోగ్య కార్యకర్తల కోసం మాత్రమే ఒక ప్రాథమిక గుర్తింపు సహాయం. "
        "అన్ని ఫలితాలను అర్హత కలిగిన వైద్య నిపుణులు ధృవీకరించాలి. "
        "ఈ ఫలితం ఆధారంగా మాత్రమే చికిత్స నిర్ణయాలు తీసుకోవద్దు."
    )
    if te.get("disclaimerFull") == te_disc:
        ok("locked TE disclaimerFull")
    else:
        fail("locked TE disclaimerFull drift")

    hi_disc = (
        "यह स्क्रीनिंग परिणाम चिकित्सीय निदान नहीं है। "
        "यह केवल प्रशिक्षित स्वास्थ्य कर्मियों के लिए एक प्राथमिक जाँच सहायता है। "
        "सभी परिणामों की पुष्टि योग्य चिकित्सक से करानी आवश्यक है। "
        "केवल इसी परिणाम के आधार पर उपचार के निर्णय न लें।"
    )
    if hi.get("disclaimerFull") == hi_disc:
        ok("locked HI disclaimerFull")
    else:
        fail("locked HI disclaimerFull drift")

    if "languageHindi" in en and hi.get("languageHindi") == "हिन्दी":
        ok("S01 Hindi label present")
    else:
        fail("languageHindi missing")

    banned = ("clinically validated", "95% accurate", "ICMR approved", "AnamoAI", "g/dL")
    blob = " ".join(en.values()) + " " + " ".join(te.values()) + " " + " ".join(hi.values())
    hit = [b for b in banned if b.lower() in blob.lower()]
    if hit:
        fail(f"banned phrase in ARB: {hit}")
    else:
        ok("no banned clinical claims in ARB")

    if "diagnostics" in en.get("tagline", "").lower():
        fail("tagline contains diagnostics")
    else:
        ok("tagline clean")


def check_docs() -> None:
    text = ""
    for name in (
        "01_PRODUCT_LOCK.md",
        "05_VISION_PIPELINE.md",
        "06_DATA_AND_API.md",
        "00_DOCUMENT_CONTROL.md",
    ):
        text += (ROOT / name).read_text(encoding="utf-8")
    if "alg-1.1.0" in text and "| `algorithm_version` | `alg-1.0.0` |" not in text:
        ok("algorithm_version pinned alg-1.1.0")
    else:
        fail("algorithm_version still lists alg-1.0.0 or missing 1.1.0")

    vis = (ROOT / "05_VISION_PIPELINE.md").read_text(encoding="utf-8")
    if "Do **not** apply a lower bound on `a*`" in vis or "Do **not** apply a lower bound on a*" in vis:
        ok("anemia filter does not floor a*")
    else:
        fail("anemia a* floor language missing from 05")

    pub = (ROOT / "engineering/pubspec.yaml").read_text(encoding="utf-8")
    if "assets/brand/" in pub and "google_mlkit_face_mesh_detection: 0.5.0" in pub:
        ok("pubspec brand assets + Face Mesh 0.5.0")
    else:
        fail("pubspec missing brand assets or wrong Face Mesh pin")

    compose = (ROOT / "backend/docker-compose.yml").read_text(encoding="utf-8")
    if "5432:5432" in compose:
        fail("compose publishes Postgres 5432")
    else:
        ok("compose does not publish Postgres")


def check_vision() -> None:
    sys.path.insert(0, str(ROOT / "vision"))
    from cielab_reference import load_goldens, max_delta, rgb255_to_lab
    from classify import classify_anemia, classify_anemia_series, classify_jaundice

    data = load_goldens()
    worst = 0.0
    for row in data["samples"]:
        worst = max(worst, max_delta(rgb255_to_lab(*row["rgb255"]), row))
    if worst <= 0.05:
        ok(f"Lab goldens worst Δ={worst:.4f}")
    else:
        fail(f"Lab goldens worst Δ={worst:.4f}")

    for row in data["classify_boundaries"]["anemia"]:
        if classify_anemia(row["a"]) != row["expect"]:
            fail(f"anemia bin {row}")
            break
    else:
        ok("anemia boundary table")

    for row in data["classify_boundaries"]["jaundice"]:
        if classify_jaundice(row["b"]) != row["expect"]:
            fail(f"jaundice bin {row}")
            break
    else:
        ok("jaundice boundary table")

    risk, signal = classify_anemia_series([])
    if risk == "UNABLE_TO_ASSESS" and signal is None:
        ok("aggregate <2 → UNABLE")
    else:
        fail("aggregate <2 failed")
    risk, signal = classify_anemia_series([4.0, 12.0])
    if risk == "MODERATE" and signal == 8.0:
        ok("aggregate n=2 uses mean")
    else:
        fail(f"aggregate n=2 got {risk} {signal}")


def check_yaml_sql() -> None:
    import yaml

    spec = yaml.safe_load((ROOT / "backend/openapi.yaml").read_text(encoding="utf-8"))
    paths = set(spec.get("paths", {}))
    need = {"/health", "/devices/register", "/sync", "/devices/revoke"}
    if need <= paths:
        ok("OpenAPI has four routes")
    else:
        fail(f"OpenAPI missing {need - paths}")

    screening = spec["components"]["schemas"]["Screening"]["properties"]
    if "device_id" in screening:
        fail("OpenAPI Screening still has device_id")
    else:
        ok("OpenAPI Screening has no device_id")

    local = (ROOT / "engineering/local_schema.sql").read_text(encoding="utf-8")
    if "deleted_at" in local:
        fail("local schema still has deleted_at")
    else:
        ok("local schema has no deleted_at")
    if "patient_name" in local:
        fail("local schema has patient_name")
    else:
        ok("local schema has no identity columns")


def check_api() -> None:
    os.environ["JWT_SECRET"] = "verify-secret"
    os.environ["ADMIN_KEY"] = "verify-admin"
    os.environ["ORG_CODES"] = "ASHA-HYD-04,DEMO"
    os.environ["VYTRA_DB"] = str(Path(tempfile.gettempdir()) / f"vytra-verify-{uuid4().hex}.db")

    # Fresh import in an isolated module path
    backend = str(ROOT / "backend")
    if backend not in sys.path:
        sys.path.insert(0, backend)
    # If app was already imported, skip reusing stale env by loading from file via TestClient
    from importlib import reload
    import app.main as main

    reload(main)
    from fastapi.testclient import TestClient

    client = TestClient(main.app)
    h = client.get("/api/v1/health")
    if h.status_code == 200 and h.json().get("ok") is True:
        ok("GET /health")
    else:
        fail(f"health {h.status_code} {h.text}")
        return

    bad = client.post("/api/v1/devices/register", json={"device_id": "d1", "org_code": "NOPE"})
    if bad.status_code == 403:
        ok("register rejects unknown org")
    else:
        fail(f"register unknown org → {bad.status_code}")

    reg = client.post(
        "/api/v1/devices/register",
        json={"device_id": "550e8400-e29b-41d4-a716-446655440099", "org_code": "ASHA-HYD-04"},
    )
    if reg.status_code != 201:
        fail(f"register {reg.status_code} {reg.text}")
        return
    token = reg.json()["access_token"]
    ok("register issues token")

    payload = {
        "screenings": [
            {
                "screening_id": "11111111-1111-4111-8111-111111111199",
                "captured_at": "2026-08-13T06:00:00Z",
                "anemia_risk": "LOW",
                "jaundice_risk": "LOW",
                "valid_anemia_count": 2,
                "valid_jaundice_count": 2,
                "algorithm_version": "alg-1.1.0",
                "threshold_version": "th-1.0.0",
                "app_version": "1.0.0",
                "consent_recorded_at": "2026-08-13T05:59:00Z",
            }
        ],
        "captures": [],
    }
    syn = client.post("/api/v1/sync", headers={"Authorization": f"Bearer {token}"}, json=payload)
    if syn.status_code == 200 and payload["screenings"][0]["screening_id"] in syn.json()["accepted_screening_ids"]:
        ok("sync accepts screening")
    else:
        fail(f"sync {syn.status_code} {syn.text}")

    leaked = dict(payload)
    leaked["screenings"] = [dict(payload["screenings"][0], patient_name="x")]
    leak = client.post("/api/v1/sync", headers={"Authorization": f"Bearer {token}"}, json=leaked)
    if leak.status_code == 400:
        ok("sync rejects patient_name")
    else:
        fail(f"sync leaked name → {leak.status_code}")

    rev = client.post(
        "/api/v1/devices/revoke",
        headers={"X-Admin-Key": "verify-admin"},
        json={"device_id": "550e8400-e29b-41d4-a716-446655440099"},
    )
    after = client.post("/api/v1/sync", headers={"Authorization": f"Bearer {token}"}, json={"screenings": [], "captures": []})
    if rev.status_code == 200 and after.status_code == 401:
        ok("revoke then 401")
    else:
        fail(f"revoke {rev.status_code} after {after.status_code}")


def check_unit_module() -> None:
    sys.path.insert(0, str(ROOT / "vision"))
    loader = unittest.TestLoader()
    suite = loader.discover(str(ROOT / "vision"), pattern="test_vision.py")
    result = unittest.TextTestRunner(verbosity=0).run(suite)
    if result.wasSuccessful():
        ok(f"unittest vision ({result.testsRun} tests)")
    else:
        fail(f"unittest vision failed ({len(result.failures)} failures)")


def main() -> int:
    print("VYTRA pack verify 1.4.0\n")
    check_files()
    check_arb()
    check_docs()
    check_vision()
    check_yaml_sql()
    check_unit_module()
    try:
        check_api()
    except Exception:
        fail("API tests crashed\n" + traceback.format_exc())

    print()
    print(f"{len(OKS)} passed  ·  {len(FAILS)} failed")
    if FAILS:
        print("FAILED:")
        for f in FAILS:
            print(f"  - {f}")
        return 1
    print("PACK GREEN")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
