# 02 — Vibe Spec (Master Build Specification)

**Read `01_PRODUCT_LOCK.md` first.** This file specifies *how* the locked product is built. Screen layouts live in `03` and `04`. Maths live in `05`. Schema and HTTP live in `06`. Strings live in `07`.

---

## 1. One-sentence product

VYTRA lets an ASHA worker, offline, on a low-end Android phone, photograph an everted lower lid and an open temporal sclera, receive anemia and jaundice **risk classes** with a next action, and share a referral PDF that never pretends to be a diagnosis.

---

## 2. End-to-end happy path

Numbered. Implement this sequence. Do not add steps.

1. Cold start. If no locale stored → **S01 Language**. Else → **S02 Home**.
2. Worker taps **New screening**.
3. **S03 Consent** in the active language. Decline → home, no row written, decline is not logged. Agree → write `consent_recorded_at`, continue.
4. **S04 Session metadata.** Worker selects Fitzpatrick I–VI (self-reported or worker-assessed; both the value and the method are stored) and lighting (`INDOOR_NATURAL` / `INDOOR_ARTIFICIAL` / `OUTDOOR_SHADE` / `OUTDOOR_DIRECT`). Both fields required.
5. **S05 White reference.** Instruction: place the rear camera 15–20 cm above a matte white A4 sheet, fill the frame, tap capture. Validate (see `05`). Fail → named guidance, unlimited retry. Success → store gains in session memory. No skip.
6. **S06 Anemia capture.** Overlay: ellipse + “pull the lower lid down, fill with pink tissue.” Quality: blur + exposure only (no EAR — the eye is everted). Up to 3 attempts. After each valid attempt show a 1-2-3 counter. Stop allowed after 2 valid. Skip-to-jaundice is **not** offered before 2 valid or 3 attempts.
7. **S07 Jaundice capture.** Overlay: ellipse on temporal sclera + Face Mesh assist if a face is found. Quality: blur + exposure + EAR > 0.2. Same 3 / 2 rule.
8. Run aggregation (`L4` in the product lock) on a compute isolate. < 3 s.
9. **S08 Results.** Two tiles. Icons + colour + label + next action. Dual-high banner if either is `HIGH`. `UNABLE_TO_ASSESS` uses a distinct neutral tile and “retake this part” action. Disclaimer visible without scroll. No numbers.
10. Worker taps **Generate PDF** → **S09** optional patient reference → generate → Android share sheet → discard the reference string.
11. Atomic write of `screenings` + `captures`. `sync_status = PENDING`.
12. Return to **S02 Home**. Sync runs later if the network appears. The worker does nothing.

---

## 3. Edge paths (implement exactly)

### E1. Consent declined
Back to home. No session object. No camera permission prompt yet (permission is requested on first entry to S05).

### E2. Patient refuses the photograph at S06 or S07
Back control → “Discard this screening? Nothing will be saved.” Confirm → wipe session memory, home. Do not write a refusal reason.

### E3. White reference invalid
Show the specific failure (too dark / colour cast / clipped). Retry. No skip, no override.

### E4. Fewer than two valid captures in a series
After the third attempt, that series is closed as `UNABLE_TO_ASSESS`. Continue to the other series or to results. Do not invent a `LOW`.

### E5. Face Mesh missing on anemia capture
Normal. Hide the mesh. Keep the static ellipse. Capture remains enabled when blur + exposure pass.

### E6. Face Mesh missing on jaundice capture
Disable capture. Prompt: “Show the whole face, look at the camera, then look toward the nose.” If 15 s elapse with no mesh, offer **ellipse-only jaundice capture** (exposure + blur only). Tag `mesh_used = 0` on that capture.

### E7. Offline
No error mentioning internet, Wi-Fi, or connection on S01–S09. Sync status lives only on **S10**.

### E8. Sync interrupted
Local row unchanged. Status `PENDING` or `FAILED`. Retry on connectivity, exponential backoff 5 s → 60 s, stop after 10 failures until next app start.

### E9. Crash between capture and DB write
No partial row. On next launch the worker starts a new screening. If the crash is *after* the atomic write, the row stands.

### E10. Dual HIGH
Results show a top banner: the locked string `bannerReferToday` (“Immediate referral recommended. Accompany the person to the PHC today.”). PDF includes the same banner.

### E11. App backgrounded mid-session
Session object survives in memory while the process lives. On process death, the session is gone (no resume of an unsaved screening). White-reference gains never persist across process death.

---

## 4. Functional requirements (compact)

Priority: **M** must, **S** should, **C** cut-first.

### 4.1 Session and consent

| ID | Pri | Requirement |
|---|---|---|
| FR-CS-01 | M | First launch shows language `te` / `en`, each labelled in its own script. Persist in shared preferences. |
| FR-CS-02 | M | New screening always opens consent in the active language. Content is the locked block in `07`. Controls: Agree / Decline. |
| FR-CS-03 | M | Agree writes `consent_recorded_at` (ISO-8601, device local, offset included) before the camera route is pushed. Write failure aborts the session. |
| FR-CS-04 | M | Decline writes nothing, including no decline event. |
| FR-MD-01 | M | S04 collects Fitzpatrick 1–6, assessment method `SELF_REPORTED` \| `WORKER_ASSESSED`, and lighting enum. Continue disabled until all three are set. |

### 4.2 White reference

| ID | Pri | Requirement |
|---|---|---|
| FR-WR-01 | M | S05 is a hard route guard. S06 is unreachable without valid gains in the current session. |
| FR-WR-02 | M | Accept only if (a) mean R, G, B each ≥ 180, (b) sample SD of the three means ≤ 15, (c) ≤ 5 % of pixels clipped at 255 in any channel. |
| FR-WR-03 | M | Gains `gC = mean(C) / 255` for C in R,G,B. Apply `C' = clamp(C / gC, 0, 1)` to ROI RGB before Lab. |
| FR-WR-04 | M | Gains discarded at session end and on process death. |
| FR-WR-05 | S | Optional torch toggle on S05. Default off. |

### 4.3 Capture and quality

| ID | Pri | Requirement |
|---|---|---|
| FR-CA-01 | M | Rear camera, `ResolutionPreset.medium`, preview on a compute-friendly YUV stream. No image written to the gallery or disk. Frames live in memory and are dropped after analysis. |
| FR-CA-02 | M | Anemia overlay = static ellipse + four coaching icons. No EAR gate. |
| FR-CA-03 | M | Jaundice overlay = ellipse on temporal half + mesh contour when available. EAR gate on. |
| FR-CA-04 | M | Blur: Laplacian variance of a 100×100 grayscale crop of the ellipse interior. Pass if `> 100`. |
| FR-CA-05 | M | Exposure: mean grayscale of that crop in `[40, 200]`. Rolling mean of 5 frames before the lamp changes state. |
| FR-CA-06 | M | EAR (jaundice only): `vert(159,145) / horiz(33,133)` (left) and `vert(386,374) / horiz(362,263)` (right). Use the eye whose temporal sclera is being targeted. Pass if `> 0.2`. |
| FR-CA-07 | M | Capture button enables only when that series’ gates all pass on the **same** frame. The saved RGB is that frame, not the next one. |
| FR-CA-08 | M | Per-series attempt counter 1–3. `capture_index` **is the attempt number** (1, 2, or 3), including invalid attempts. Do not reuse an index. After 2 valid, primary button becomes “Use these” and a secondary “Take one more” remains until 3. |
| FR-CA-09 | S | If preview FPS < 15 for 3 s, drop mesh drawing and directional arrows. Keep the ellipse. Never show a crash or “performance error.” |
| FR-CA-10 | M | Minimum valid pixels after filters: anemia 300, jaundice 200. Below that the attempt is invalid with reason `ROI_TOO_SMALL`. |

### 4.4 Analysis

| ID | Pri | Requirement |
|---|---|---|
| FR-AI-01 | M | Isolate (`compute`) runs white-patch → mean RGB → true Lab. Matches `vision/golden_cielab.json` ± 0.05. |
| FR-AI-02 | M | Anemia class from median a\* of valid lid captures via `th-1.0.0`. |
| FR-AI-03 | M | Jaundice class from median b\* of valid sclera captures via `th-1.0.0`. |
| FR-AI-04 | M | `< 2` valid → `UNABLE_TO_ASSESS` and null signal. Enforced in the Bloc before insert. |
| FR-AI-05 | M | ASHA surfaces never receive a\*, b\*, L\*. Research mode may. Gated by `--dart-define=DEBUG_LAB=true` **or** research PIN, never both leaking into the study APK. Study APK: `DEBUG_LAB=false`. |
| FR-AI-06 | M | `algorithm_version = alg-1.1.0`, `threshold_version = th-1.0.0`, `app_version` from package_info. All NOT NULL. |

### 4.5 Results and PDF

| ID | Pri | Requirement |
|---|---|---|
| FR-RD-01 | M | One screen, both conditions, no tabs, no required scroll on 720×1280. |
| FR-RD-02 | M | Each class has a unique **shape** icon (not colour alone) plus red / amber / green / slate. |
| FR-RD-03 | M | Next-action strings exactly as `07`. |
| FR-RD-04 | M | Disclaimer rules in `L8`. Automated test asserts the key is rendered. |
| FR-PDF-01 | M | Optional patient reference. Discarded after file write. |
| FR-PDF-02 | M | On-device, < 5 s, Noto Sans Telugu + Noto Sans Devanagari not required (no Hindi). Embed `NotoSansTelugu-Regular.ttf` and `NotoSans-Regular.ttf`. |
| FR-PDF-03 | M | Filename `SCREEN_YYYYMMDD_XXXX.pdf` where `XXXX` is 4 crypto-random alphanumeric chars. |
| FR-PDF-04 | M | Contents: app + version, patient ref or `[Not provided]`, datetime, both classes, both actions, dual-high banner if applicable, full disclaimer, footer “Generated by VYTRA vX.X. This is not a medical document. For use by trained ASHA workers only.” No Lab values, no device model, no Fitzpatrick. |
| FR-PDF-05 | M | Share via `share_plus` + FileProvider. Test on API 26, 29, and 34. |

### 4.6 Storage, sync, offline

| ID | Pri | Requirement |
|---|---|---|
| FR-LS-01 | M | One SQLite transaction writes the screening and its captures. Failure surfaces “Could not save. Try again.” and keeps the result on screen. |
| FR-LS-02 | M | AES-256 via SQLCipher. Key created once, stored in Android Keystore through `flutter_secure_storage`. Path = `getDatabasesPath()`. |
| FR-LS-03 | M | Core schema exactly `06`. If `SECONDARY_TOOLS=true`, also create `secondary_scans` from `11` — never extra columns on `screenings`. |
| FR-SY-01 | M | Sync never blocks S01–S09. |
| FR-SY-02 | M | Payload fields exactly `06`. No patient reference. |
| FR-SY-03 | M | Bearer token from register endpoint. 401 → mark `FAILED`, do not wipe local data. |
| FR-SY-04 | M | Local wins. |
| FR-SY-05 | S | S10 shows Synced / Pending / Failed only. |
| FR-OF-01 | M | Airplane-mode walkthrough of §2 steps 1–12 succeeds. |
| FR-RT-01 | M | Retention worker: no network constraint, period 6 h, deletes eligible rows. Language in UI and consent: eligible, not exact. |

### 4.7 Localization and research

| ID | Pri | Requirement |
|---|---|---|
| FR-L10N-01 | M | Every worker-facing string from ARB files. No inline English fallbacks except missing-key fallback. |
| FR-L10N-02 | M | No medical term without the plain-language equivalent on the same screen. Prefer the plain phrase alone. |
| FR-RS-01 | S | Hidden gesture on the home version label (5 taps) → PIN → research view of the last screening. |
| FR-SEC-01 | C | If `SECONDARY_TOOLS=true`, S02 shows a secondary **More tools** link to S13. Never as the primary CTA. Spec: `11_SECONDARY_MODULES.md`. |

---

## 5. Non-functional

| Area | Target | Type |
|---|---|---|
| Preview FPS (jaundice, reference device) | ≥ 20 for 30 s | Hard |
| Analysis latency | < 3 s after last capture | Hard |
| PDF | < 5 s | Hard |
| Cold start | < 4 s | Hard |
| Battery, full session | < 2 % at 50 % brightness | Soft |
| Disclaimer render | 100 % | Safety |
| Min SDK | 26 | Hard |
| Test API levels | 26, 29, 34 | Hard |
| Analytics / crash SDKs | **None** | Hard |
| Cleartext HTTP | Off (`usesCleartextTraffic=false`) | Hard |

Degrade: FPS < 15 for 3 s → static ellipse. Quality gates stay live.

---

## 6. Domain objects (Dart names)

```
enum LocaleCode { te, en }
enum Lighting { indoorNatural, indoorArtificial, outdoorShade, outdoorDirect }
enum FitzpatrickMethod { selfReported, workerAssessed }
enum Series { anemia, jaundice }
enum Risk { low, moderate, high, unableToAssess }
enum SyncStatus { pending, synced, failed }
enum RejectionReason { blur, exposureDark, exposureBright, eyeClosed, roiTooSmall,
                       whiteRefFail, meshMissing, other }

class WhiteGains { double r, g, b; }          // session memory only
class CaptureAttempt { ... }                  // see schema
class Screening { ... }                       // see schema
class SessionDraft {                          // never persisted
  String screeningId;
  DateTime consentAt;
  int fitzpatrick;
  FitzpatrickMethod method;
  Lighting lighting;
  WhiteGains? gains;
  List<CaptureAttempt> anemia;
  List<CaptureAttempt> jaundice;
}
```

---

## 7. Navigation graph

```
S01 Language          → S02
S02 Home              → S03 | S10 | S11 Settings | S13 More tools | (hidden) S12 Research
S03 Consent           → S04 | S02
S04 Metadata          → S05 | discard→S02
S05 White reference   → S06 | discard→S02
S06 Anemia series     → S07 | discard→S02
S07 Jaundice series   → S08 | discard→S02
S08 Results           → S09 | S02
S09 PDF               → share sheet → S08
S10 Sync status       → S02
S11 Settings          → language change rebuilds tree → S02
S12 Research          → S02
S13 More tools        → S14 | S17 | S02
S14–S20 Skin / Teeth  → 11_SECONDARY_MODULES.md
```

Route guard: `gains == null` blocks S06–S09.

No deep links.

---

## 8. Permissions

Request on the **first** screen that needs the camera (normally S05; S15 or S18 if secondary tools are opened first).

| Permission | When | If denied |
|---|---|---|
| `CAMERA` | First of S05 / S15 / S18 | Stay on that screen with “Camera permission is required to screen.” No storage, location, contacts, SMS, Bluetooth. |

Do **not** request location. The older stack note about Android 13 location / Bluetooth is void.

Manifest also needs `INTERNET` (for optional sync), `WAKE_LOCK` only if WorkManager requires it on API 26. No `READ_MEDIA_*`. No `WRITE_EXTERNAL_STORAGE` on API 29+.

---

## 9. Build flavours

| Flavour | `DEBUG_LAB` | `RESEARCH_PIN` | Backend | Use |
|---|---|---|---|---|
| `study` | false | set | study server | Volunteer APK |
| `demo` | false | set | mock / local | SIH stage, airplane mode |
| `dev` | true | local-only PIN via dart-define | localhost | Team only |

The study APK is what volunteers touch.

---

## 10. Explicit non-goals (v1)

- Neonatal capture path or kernicterus-specific copy
- Hindi
- RITnet, iris-refine landmarks (ML Kit Face Mesh may not expose 468–477)
- Treating skin/teeth demos as diagnoses, or putting them on the home primary CTA
- ABDM / ABHA
- Device ICC profiles
- Hemoglobin / bilirubin estimation
- Play Store, OAuth, refresh-token rotation, client PKI
- History of past patients on the home screen (would pressure the worker to store identity)
- Analytics, Firebase, crashlytics
- iOS

---

## 11. Suggested 10-day build order

Agents should still implement **vertically** (one thin slice that runs) rather than layer-by-layer.

| Day | Slice |
|---|---|
| 1 | Flutter scaffold, l10n, S01–S03, Telugu font in UI, golden Lab unit tests |
| 2 | Camera + S05 white-ref validation |
| 3 | S06 ellipse capture + blur/exposure + isolate Lab |
| 4 | S07 mesh + EAR + temporal mask |
| 5 | Series counter, median, `UNABLE_TO_ASSESS` |
| 6 | S08 results + locked disclaimer layout on a 720×1280 emulator |
| 7 | SQLCipher schema + atomic write + S09 PDF + share |
| 8 | WorkManager retention + sync client + FastAPI docker |
| 9 | Airplane-mode QA, API 26 device, Telugu PDF tofu check |
| 10 | Study flavour, pin, demo script, cut anything not in the M list |

Cut order if late: **S13–S20 skin/teeth** → S12 research → S10 polish → live sync (mock it) → Hindi (already cut) → third capture (allow stop at 2).

Skin and teeth are specified in `11_SECONDARY_MODULES.md`. Build them only after Day 7 of the core path is green.
