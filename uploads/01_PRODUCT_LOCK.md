# 01 — Product Lock

These decisions are closed for v1. A coding agent must not reopen them. A human may change them only via a pack version bump (see `00_DOCUMENT_CONTROL.md`).

---

## L1. What we are building

An **offline-first Android application** used by an ASHA worker during a household visit.

From two kinds of photograph it computes colourimetric signals and returns **risk classes**, not laboratory values.

| Condition | Tissue | Signal | Output |
|---|---|---|---|
| Anemia screening | Everted **lower palpebral conjunctiva** (inner pink of the pulled-down lid) | True CIELAB **a\*** (red–green) | `LOW` / `MODERATE` / `HIGH` / `UNABLE_TO_ASSESS` |
| Jaundice screening | **Temporal sclera** of an open eye (the white, not the iris, not the lid) | True CIELAB **b\*** (yellow–blue) | `LOW` / `MODERATE` / `HIGH` / `UNABLE_TO_ASSESS` |

It is a **triage aid**. It is **not** a medical device, not a hemoglobinometer, not a bilirubinometer, and not a diagnosis.

**Secondary (optional, internet):** a skin-lesion demo (Hugging Face) and a teeth-alignment demo (Roboflow). They are **not** the ASHA product. Spec: `11_SECONDARY_MODULES.md`. They may be compiled out. They never write into the core `screenings` table. They require a separate consent that the photo leaves the device.

---

## L2. Who it is for

| Actor | Uses the app? | Goal |
|---|---|---|
| **ASHA worker** (primary) | Yes | Finish a screening in under five minutes, get a plain-language next action, leave with a PDF. |
| **Patient / guardian** | No | Gives consent. Does not operate the app. |
| **PHC medical officer** | No | Reads the PDF. Confirms or dismisses with clinical tools. |
| **Study team** (research mode) | Yes, PIN-gated | Inspect a\*, b\*, quality sub-scores, versions. Never shown to the ASHA. |

Literacy assumption: Telugu or English. Icon-first navigation. No screen in the core flow is English-only.

Device assumption: Android 8.0 (API 26)+, 8 MP rear camera, reference hardware Snapdragon 665 / 4 GB RAM. Distribution is **sideloaded APK**, not Play Store.

---

## L3. Who it is not for (v1)

| Out | Why |
|---|---|
| **Neonates** | ML Kit Face Mesh is an adult/child selfie model. Newborn faces fail detection. Kernicterus messaging without a working capture path is unsafe. Neonatal jaundice is **v2**. |
| Hindi-first users | Telugu + English ship. Hindi is the first language cut if time slips. |
| Self-screening patients | Copy and consent assume a trained worker. |
| iOS | Face Mesh plugin is Android-only Beta. |

---

## L4. Capture protocol (closed)

One **screening** contains:

1. Consent
2. Session metadata (Fitzpatrick + lighting) — required
3. One **white-reference** photograph (hard gate)
4. **Anemia series** — up to 3 everted-lid photographs
5. **Jaundice series** — up to 3 open-eye temporal-sclera photographs
6. Aggregation → result → optional PDF

**Aggregation rule (enforced in the Bloc, not in the widget):**

```
valid = captures in series where valid = 1
if count(valid) < 2:
    risk = UNABLE_TO_ASSESS
    a_star / b_star = NULL
else:
    value = median(valid values)
    risk = classify(value)
```

A series may stop early once 2 valid captures exist (the third is optional). The worker may take a third to improve the median. Maximum 3 attempts per series.

Quality-gate override after 3 consecutive failures of a *single attempt* is **not** in v1 (cut). If the worker cannot get 2 valid frames, the condition is `UNABLE_TO_ASSESS`. The other condition may still classify.

---

## L5. How the tissue is actually photographed

Face Mesh landmarks `33, 133, 159, 145` bound the **open palpebral fissure**. They do **not** expose the palpebral conjunctiva.

| Series | Choreography the worker is shown | What is measured |
|---|---|---|
| Anemia | “Ask the person to look up. Gently pull the lower lid down until the inner pink tissue is visible. Fill the guide with the pink tissue.” | Pixels inside the guide ellipse after pale-skin / lash rejection |
| Jaundice | “Ask the person to look toward their nose so the outer white of the eye is large. Do not pull the lid. Keep lashes out of the white.” | High-L\*, low-chroma pixels in the temporal half of the eye opening |

When lid eversion distorts the face, Face Mesh will often drop. **That is expected.** Anemia capture **must** work with the static ellipse guide alone. Face Mesh is an assist for jaundice (open eye), not a dependency for anemia.

See `05_VISION_PIPELINE.md` for polygons, filters, and minimum pixel counts.

---

## L6. Thresholds — prototype heuristics, not literature cutoffs

These numbers are **v1 prototype bins** so the app can return a class. They are **not** Tamir et al. (2017) cutoffs. Tamir used RGB red-versus-green thresholding on n = 19. They are **not** Skinopathy (arXiv:2603.00161) bins. Skinopathy uses OpenCV-scaled Lab and a continuous index.

`threshold_version` = `th-1.0.0`

| Anemia (conjunctival a\*) | Class |
|---|---|
| `a* < 5` | `HIGH` |
| `5 ≤ a* < 10` | `MODERATE` |
| `a* ≥ 10` | `LOW` |

| Jaundice (scleral b\*) | Class |
|---|---|
| `b* ≥ 15` | `HIGH` |
| `10 ≤ b* < 15` | `MODERATE` |
| `b* < 10` | `LOW` |

Never show these numbers to the ASHA. Store them for research mode and sync.

If a future study replaces the bins, bump `threshold_version`. Do not silently edit.

---

## L7. Colour science (closed)

- Convert **mean RGB of the filtered ROI** once — not per-pixel then average Lab.
- Pipeline: sRGB (gamma encoded 0–1) → linear sRGB → CIE XYZ (D65, IEC 61966-2-1 matrix) → CIELAB (D65 white `Xn=0.95047, Yn=1.00000, Zn=1.08883`, 2°).
- Output is **true Lab**: `L* ∈ [0,100]`, `a*`/`b*` typically `[-128, 127]`.
- **Forbidden:** OpenCV `COLOR_RGB2LAB` uint8 (`L' = L* × 255/100`, `a' = a* + 128`). Using it with the bins above makes every result wrong.
- White-patch: per-channel gain from the reference, applied to ROI RGB **before** Lab. Gains live in session memory only.

Canonical implementation: `vision/cielab_reference.py`. Golden oracles: `vision/golden_cielab.json`. Dart must match to **±0.05** on `L*, a*, b*` for every golden row.

---

## L8. Safety copy (closed)

Every result screen and every PDF **must** show, in the active language, verbatim:

> This screening result is not a medical diagnosis. It is a triage aid for trained health workers only. All results require confirmation by a qualified medical professional. Do not make treatment decisions based on this result alone.

Rules: full text; ≥ 12 sp; contrast ≥ 4.5:1; not behind a toggle; visible without scrolling on a 5-inch 720×1280 screen; same language as the rest of the screen.

**The app must never claim, on any surface:**

- that a result is accurate, validated, approved, or a diagnosis
- a hemoglobin or bilirubin number
- “no further testing is needed”
- FDA / CDSCO / CE / ICMR certification
- raw `a*` / `b*` / `L*` to the ASHA or on the PDF

Telugu locked text lives in `07_LOCALIZATION.md` and `l10n/app_te.arb`.

---

## L9. Data rules (closed)

**Stored locally (encrypted SQLite):** screening row + capture rows as specified in `06_DATA_AND_API.md`. Includes risk classes, a\*/b\* for research, quality scores, device model, Fitzpatrick, lighting, algorithm/threshold/app versions. No name.

**Never stored, never synced:** patient name, household ID, photograph bytes, face geometry, iris pattern, GPS, ASHA name/phone/ID.

**Patient reference:** typed at PDF generation, written into the PDF header, then the Dart variable is discarded. Optional. Blank → `Patient: [Not provided]`.

**Retention:** `captured_at` is ISO-8601 **UTC** (`…Z`). A record is **eligible for deletion** when that UTC timestamp is more than 30 calendar days before `now` (UTC). It is **permanently deleted on the next successful run of the retention worker**. WorkManager timing is best-effort. Consent form and UI must use the word **eligible**, never “exactly 30 days.”

**Uninstall:** database lives in app internal storage and dies with the app. Server copies follow the server schedule independently. Both facts are in the consent form.

---

## L10. Auth and sync (closed)

- Core screening **never** requires a network.
- First launch that has connectivity: `POST /api/v1/devices/register` with `{ device_id, org_code }`. Server returns a bearer token. Stored in `flutter_secure_storage`.
- Sync: `POST /api/v1/sync` with `Authorization: Bearer <token>`.
- No shared API key in the APK. No client-side public/private keypair in v1.
- Conflict rule: **local wins** (`ON CONFLICT DO UPDATE` from the payload).
- `org_code` is compiled in via `--dart-define=ORG_CODE=...` (this is a study-site code, not a secret that protects health data).

---

## L11. Languages and modes

| Item | v1 |
|---|---|
| UI languages | `te`, `en` |
| Fallback | English, with a debug log if a Telugu key is missing |
| Default after first run | Last chosen locale |
| ASHA mode | Default. Classes + actions + disclaimer only. |
| Research mode | PIN required via `--dart-define=RESEARCH_PIN` on study/demo APKs (do **not** ship the dev example `2580`). Shows numbers. Not linked from the home screen iconography as a primary action. |

---

## L12. Stack pins (closed)

| Layer | Choice |
|---|---|
| Flutter | 3.44 stable, or whatever `flutter --version` reports if ≥ 3.35. Do not install 3.22. |
| State | `flutter_bloc` 9.1.1 |
| Camera | official `camera` 0.11.2 (use 0.12.x only if the Flutter SDK is ≥ 3.35 and `pub get` resolves) |
| Face mesh | `google_mlkit_face_mesh_detection` **0.5.0** (Android only) |
| Local DB | `sqflite_sqlcipher` 3.4.1 |
| PDF | `pdf` 3.11.3 + `printing` 5.14.2 + `share_plus` 10.1.4 |
| Backend | FastAPI 0.115 + PostgreSQL 16. SQLite file backend is the documented fallback. |

Exact YAML: `engineering/pubspec.yaml`.

---

## L13. Success bar for the 14-day build

A build is a v1 demo when all of the following are true on the reference device:

- Cold start < 4 s to language or home
- AR / preview ≥ 20 FPS for 30 s in jaundice (open-eye) mode
- Classification of both series < 3 s after the last valid capture
- PDF < 5 s, Telugu glyphs render (not tofu)
- Disclaimer present on result and PDF, both languages
- Airplane mode: full screening + PDF still works
- `< 2` valid anemia captures writes `UNABLE_TO_ASSESS`, not `LOW`
- `adb` opening the DB file without the key fails
- No patient name in `sqlite` after a named PDF was generated

Clinical accuracy is **not** a v1 pass/fail. The volunteer study, if run, is a feasibility study (n ≈ 20), not a diagnostic trial.

---

## L14. Brand lock

Official artwork: `design/vytra_logo_lockup.png` and `design/vytra_mark.png`. Rules in `design/BRAND.md`.

| Item | Value |
|---|---|
| Display name (forms / speech) | **VYTRA** |
| Visual wordmark | lowercase **vytra** — only as the PNG, never redrawn |
| Pronunciation | VYE-trah |
| Package / code | `vytra` |
| Category line (under lockup only) | AI HEALTH SCREENING |
| Tagline | See Health. Detect Early. |
| Mark | Forest **V** + lime **leaf-pulse** + lime **dot** |
| Colours | Forest `#0E2A1C` · Pulse `#6CA532` |
| Expansion (pitch deck only) | Vision + Vitality + Tracking + AI |
| Letters (pitch deck only) | **V** Vision · **Y** Your health · **T** Tracking · **R** Recognition / Response · **A** AI / Analysis |

**Where the lockup may appear:** S01, splash, S02 home header, PPT title, PDF header (small mark).

**Where the tagline / category line must not appear:** S08 results, PDF body, PDF footer, consent body, any risk tile.

**Banned on every worker surface:** the designer note “vitality + diagnostics”, the word **diagnostics**, and the backronym. Those read as a clinical claim.

The name is not translated. The safety line under the lockup stays localised (`languageFooter`).

Former working title **AnamoAI** is retired. Do not print it on any v1 surface.

---

## L15. Citation lock (for pitch and code comments)

| Source | Allowed use | Forbidden use |
|---|---|---|
| Tamir et al., IEEE R10-HTC 2017 | “Prior smartphone conjunctiva work using RGB R/G thresholding, n=19, 78.9% agreement.” | “Source of our a\* cutoffs.” |
| Skinopathy AI, arXiv:2603.00161 | “Contemporaneous non-diagnostic smartphone ophthalmic prototype using LAB statistics.” | “Clinical validation of b\* ≥ 15.” |
| Dimauro and later CIELAB conjunctiva papers | Optional related work for the pitch | Do not copy their unpublished cutoffs without writing the citation into this pack first. |

Code comments above the classifier must say `prototype heuristic th-1.0.0`, not `per Tamir 2017`.
