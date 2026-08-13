# Implementation Plan: VYTRA v1 first shippable demo

## Overview

Build the offline ASHA path specified in `vytra-vibespec/` (pack **1.4.0**: `te` / `hi` / `en`). Fix the three review blockers on the study stub first so sync cannot be pointed at a network by accident. Then one vertical slice at a time: Lab tests → S01–S03 → white-ref → anemia → jaundice → results+PDF. Sync last. Skin/teeth out unless a human sets `SECONDARY_TOOLS=true` after the PDF path is green.

Authority: `01_PRODUCT_LOCK.md` then `02_VIBE_SPEC.md`. Strings only from `l10n/*.arb`. Maths only from `vision/`.

## Architecture decisions

- Android only. minSdk 26. No iOS.
- Copy `engineering/pubspec.yaml`. Face Mesh **0.5.0**.
- True CIELAB D65 2°, ±0.05 vs `golden_cielab.json`. Never OpenCV Lab.
- SQLCipher local DB from `engineering/local_schema.sql`. No name, photo, GPS columns.
- Study API stays optional. Default study/demo APK: `DEBUG_LAB=false`, `SECONDARY_TOOLS=false`.
- Do not put the API on a public host until T1 is done.

## Dependency graph

```
T0 pack stays green
    │
    ├── T1 API ownership + secrets + no un-revoke     (fail-fast, no Flutter)
    │
    └── T2 flutter create + copy locked files
            │
            ├── T3 Dart Lab + classify tests green     (high risk, first)
            │
            └── T4 S01 → S02 → S03 (te/en)
                    │
                    └── T5 S04 metadata + discard
                            │
                            └── T6 S05 white-ref hard gate
                                    │
                                    ├── T7 S06 anemia series
                                    │       │
                                    └── T8 S07 jaundice series
                                            │
                                            └── T9 S08 results + disclaimer layout
                                                    │
                                                    └── T10 S09 PDF + share; name discarded
                                                            │
                                                            ├── T11 local SQLCipher save
                                                            └── T12 sync client (only if T1 done)
```

## Task list

### Phase 0 — Do not make the stub dangerous

#### Task 1: Close review Critical 1–3 on the study API

**Description:** Stop IDOR, stop re-register from un-revoking, refuse default JWT/admin secrets except explicit `VYTRA_ENV=dev`.

**Acceptance criteria:**
- [ ] `ON CONFLICT` updates a screening only when `device_id = jwt.sub`; else reject
- [ ] Capture insert requires that screening’s `device_id = jwt.sub`
- [ ] Register on a revoked device returns 401 and leaves `revoked_at` set
- [ ] Process exits non-zero if `JWT_SECRET` is missing or the baked default unless `VYTRA_ENV=dev`

**Verification:**
- [ ] `PYTHONPATH=backend python3 -m unittest backend.tests.test_api -v` (extend tests for the three cases)
- [ ] `python3 tools/verify_pack.py` still PACK GREEN

**Dependencies:** None  
**Files:** `backend/app/main.py`, `backend/tests/test_api.py`  
**Scope:** S

### Checkpoint: API

- [ ] Cannot steal another device’s row
- [ ] Cannot un-revoke via register
- [ ] Human says whether sync is in scope for the college demo (default: no)

---

### Phase 1 — First running app

#### Task 2: Scaffold Android app and copy the lock

**Description:** `flutter create` Android-only, replace pubspec, copy ARB, brand, icons, goldens, Dart vision, theme, versions.

**Acceptance criteria:**
- [ ] `vytra_app/` exists with `minSdk = 26`
- [ ] `assets/brand/` and `lib/l10n/*.arb` present
- [ ] `flutter pub get` succeeds

**Verification:**
- [ ] `bash tools/bootstrap.sh` or the same steps by hand
- [ ] Noto Sans + Noto Sans Telugu Regular/SemiBold in `assets/fonts/` (Day-1 go/no-go)

**Dependencies:** None (parallel with T1)  
**Files:** `vytra_app/**` (new), fonts  
**Scope:** M

#### Task 3: Dart Lab + classify oracles

**Description:** Wire `reference/lib/src/vision/` so `flutter test test/cielab_test.dart` matches Python Δ ≤ 0.05 and the boundary table.

**Acceptance criteria:**
- [ ] Every golden row ±0.05
- [ ] Anemia/jaundice boundaries exact
- [ ] `< 2` valid → `UNABLE_TO_ASSESS`; n=2 median is the mean

**Verification:**
- [ ] `flutter test test/cielab_test.dart`
- [ ] If this fails, **stop**. Do not open the camera.

**Dependencies:** T2  
**Files:** `lib/src/vision/cielab.dart`, `classify.dart`, `test/cielab_test.dart`  
**Scope:** S

#### Task 4: S01 Language → S02 Home → S03 Consent

**Description:** First worker-visible path. Official lockup PNG. ARB strings only. Decline writes nothing.

**Acceptance criteria:**
- [ ] First launch shows తెలుగు + English
- [ ] Home CTA is only “New screening”; tagline on S01/S02 only
- [ ] Consent body is `consentBody` verbatim; Agree writes `consent_recorded_at` before leaving; Decline → home, no row

**Verification:**
- [ ] Widget tests for locale persist + decline writes 0 rows
- [ ] Manual: Telugu consent has no tofu

**Dependencies:** T2  
**Files:** `lib/src/features/language/`, `home/`, `consent/`, `app.dart`  
**Scope:** M

### Checkpoint: First slice

- [ ] Lab tests green
- [ ] S01–S03 run on an API 26 emulator
- [ ] Human reviews Telugu consent before T5

---

### Phase 2 — Capture path (one series at a time)

#### Task 5: S04 metadata + discard dialog

**Acceptance criteria:**
- [ ] Continue disabled until Fitzpatrick 1–6 + method + lighting
- [ ] Back shows `discardTitle` / `discardBody`; confirm wipes session, no DB row

**Verification:** widget test continue-disabled; discard leaves 0 rows  
**Dependencies:** T4  
**Scope:** S

#### Task 6: S05 white-reference hard gate

**Acceptance criteria:**
- [ ] S06 unreachable without valid gains in this process
- [ ] Accept/reject rules from `05` §3; no skip
- [ ] Gain `< 0.05` → `whiteRefFailDark`

**Verification:** unit tests on accept/reject with synthetic RGB; manual brown-desk reject  
**Dependencies:** T3, T5  
**Scope:** M

#### Task 7: S06 anemia series

**Acceptance criteria:**
- [ ] Static ellipse; Face Mesh optional and often missing
- [ ] `capture_index` 1–3 including failures; UNIQUE holds
- [ ] After 2 valid: “Use these” / “Take one more”
- [ ] 3 invalid → series `UNABLE_TO_ASSESS`, jaundice still offered
- [ ] No `a*` floor on pixels (`05` §5.1)

**Verification:** Bloc tests for the state machine; no JPEG on disk  
**Dependencies:** T6  
**Scope:** M

#### Task 8: S07 jaundice series

**Acceptance criteria:**
- [ ] EAR > 0.2 when mesh present; 15 s ellipse-only fallback, `mesh_used = 0`
- [ ] Temporal half via inner→outer axis, not raw x
- [ ] Same 3/2 rule as anemia

**Verification:** EAR unit test; fallback arms after 15 s in a test clock  
**Dependencies:** T7  
**Scope:** M

### Checkpoint: Capture

- [ ] Airplane mode: white paper + 2 lid + 2 sclera reaches analysis
- [ ] Cover lens ×3 → anemia Unable, jaundice still runs

---

### Phase 3 — Result the ASHA can hand over

#### Task 9: S08 results + locked disclaimer

**Acceptance criteria:**
- [ ] Two tiles, shape+colour (triangle/diamond/circle/dash-square)
- [ ] Dual HIGH shows `bannerReferToday`
- [ ] `disclaimerFull` visible, ≥12 sp, no overflow at 360×640 in `te` and `en`
- [ ] No a*, b*, L*, Hb, tagline, or backronym

**Verification:** `test/disclaimer_layout_test.dart` (T-DIS-01)  
**Dependencies:** T7, T8, T3  
**Scope:** M

#### Task 10: S09 PDF, name discarded

**Acceptance criteria:**
- [ ] Optional name on PDF only; SQLite has no name after share
- [ ] Footer `pdfFooter`; disclaimer in a box
- [ ] Telugu glyphs, not tofu
- [ ] Filename `SCREEN_YYYYMMDD_XXXX.pdf`

**Verification:** M-PDF-01 (open DB, no name); M-PDF-02 Telugu  
**Dependencies:** T9  
**Scope:** M

#### Task 11: Atomic SQLCipher write

**Acceptance criteria:**
- [ ] One transaction: screening + captures
- [ ] Crash after first statement → 0 or all rows
- [ ] `adb` sqlite3 without key fails
- [ ] `captured_at` is UTC `…Z`

**Verification:** T-SCH-01, D-ENC-01  
**Dependencies:** T9  
**Scope:** S

### Checkpoint: Demo path (college / SIH stage)

- [ ] Airplane mode S01→S09 + Files share
- [ ] T-LAB-01, T-AGG-01, T-DIS-01, M-OFF-01, M-PDF-01
- [ ] **Stop here for nomination.** Sync is optional.

---

### Phase 4 — Only if a human asks

#### Task 12: Sync client

**Acceptance criteria:**
- [ ] Airplane mode still never mentions internet on S01–S09
- [ ] Bearer from register; 401 → re-register once, then FAILED
- [ ] Payload has no `patient_name` / `patient_ref` (T-PAY-01)
- [ ] Demo flavour: `API_BASE_URL` empty → no-op, rows stay PENDING

**Dependencies:** T1, T11  
**Scope:** M

**Cut list (do not plan unless asked):** S12 research PIN, S10 polish, Hindi, neonates, skin/teeth, Play Store.

## Risks

| Risk | Impact | Mitigation |
|---|---|---|
| Flutter not on this Arena host | High | T2–T11 on a machine with Flutter ≥ 3.35; keep pack verify here |
| Face Mesh dies on everted lid | Med | Designed: anemia is ellipse-only |
| Telugu PDF tofu | High | Fonts on T2; fail the day, not Day 11 |
| Phone colour disagreement | Med | White-ref required; no accuracy claim |
| Someone compose-up’s the stub early | High | T1 first; default secrets must not boot |

## Open questions (human)

1. Is the college demo **airplane-mode only**? (Recommended: yes. Skip T12.)
2. Faculty mentor + PS ID still blank on the roster — not a code block, blocks submit.
3. Confirm Flutter SDK version on the build laptop (`flutter --version` ≥ 3.35).

## Standing Definition of Done (every task)

- Acceptance criteria for **that** task met
- No new medical copy, thresholds, or schema columns
- `python3 tools/verify_pack.py` still green if pack files changed
- No name / photo / GPS persisted
- Human has seen the checkpoint before the next phase
