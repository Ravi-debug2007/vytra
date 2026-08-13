# AnamoAI Document Audit — Are These Enough to Vibe-Code?

**Date:** 2026-08-12  
**Verdict:** **No. Not perfect. Not consistent. Not enough.**

You have *enough narrative* to pitch, and *almost enough engineering intent* to start a scaffold. You do **not** have a single source of truth an AI coder can follow without inventing half the product. If you paste all six files into Cursor / Claude / Copilot today, you will get a Frankenstein: one-shot capture *and* 3-shot median, API-key auth *and* device JWT, `HIGH/MODERATE/LOW` *and* `UNABLE_TO_ASSESS`, adult Face Mesh *and* neonatal jaundice.

That is the actual risk. Not missing adjectives.

---

## 1. What you actually have

| File | Role | Quality | Use for vibe-coding? |
|---|---|---|---|
| `AnamoAI_PRD__2_.md` (v1.0 DRAFT, 2025-01-27) | Real product spec. Users, FRs, edge cases, NFRs, cut list. | Best document in the set. Still a draft. | **Primary**, after contradictions are killed |
| `TECHNICAL_STACK_v1_2.md` | Implementation blueprint. Schema, auth, workers, folder tree. | Strong, but it *rewrites* the PRD | **Secondary**, only after it is merged into the PRD |
| Short PRD v1.4 “Ready for Submission” | Lean SIH one-pager | Clean, but a *different, smaller product* | Pitch only. Do not code from this. |
| Technical Implementation Guide v2.2 | 10-day lean build | Same lean product as short PRD | Pitch / team briefing only |
| Strategic Roadmap (14 days) | Calendar + roles | Useful as a calendar, not as a spec | Scheduling only |
| Technical Defense Guide v2.1 | Judge scripts | Honest on sensor variance. Weak on citations. **Author field says “Manus AI”.** | Defense only. Strip the author line before any judge sees it. |

You are maintaining **two products**:

- **Product A (lean SIH pack):** one photo → CIELAB → High/Mod/Low → local SQLite → optional FastAPI. Skin/teeth/RITnet explicitly cut.
- **Product B (AnamoAI + Stack v1.2):** ASHA field tool. Consent, Telugu/Hindi, white-reference hard gate, AES-256, 30-day deletion, PDF referral, device-token auth, 3-capture median, Research Mode PIN, Fitzpatrick logging, `UNABLE_TO_ASSESS`.

Vibe-coding needs **one** of these. Not both.

---

## 2. Fatal contradictions (the AI will pick at random)

### 2.1 Capture protocol

| Topic | AnamoAI PRD | Stack v1.2 | Lean PRD / Guide |
|---|---|---|---|
| How many photos | **One** successful capture | **3 max / 2 valid min / median** | One |
| Failed quality | Override after 3 failures, still classify | `< 2` valid → **`UNABLE_TO_ASSESS`** (must write that in DB, not just hide in UI) | Button disabled until gates pass |
| Risk enum | `HIGH / MODERATE / LOW` | adds `UNABLE_TO_ASSESS` | three-tier only |

This is not a wording difference. It is a different state machine, schema, results screen, PDF, and study analysis.

### 2.2 Auth

| AnamoAI PRD FR-SY.003 | Stack v1.2 §3.2 |
|---|---|
| Shared API key via `--dart-define` | Explicitly **rejects** that as extractable from the APK |
| `X-API-Key` | Device UUID + keypair → JWT + signed payloads + `org_code` + revocation |

Stack is right that a static key is extractable. Stack is **wrong** that “Keystore-backed non-exportable private key” can also be used by Dart to `X-Signature` the JSON. Non-exportable Android Keystore keys are used via `Signature.getInstance` on the platform side, not by reading bytes into Dart. As written, an AI will generate a PEM in `flutter_secure_storage` and call it Keystore. That is not what you claimed.

For a 14-day SIH prototype: **HTTPS + `org_code` + per-device UUID + server-issued token** is enough. Drop the homemade PKI.

### 2.3 Deletion clock

- PRD FR-LS.005: deleted **exactly** 30 calendar days, scheduler at launch + every 24h.
- Stack: WorkManager, **eligible** at 30 days, timing is OS-best-effort. Correctly walks back the PRD.
- Consent form (not written) must match **one** of these sentences. If they disagree, that is an ethics bug, not a code bug.

### 2.4 Lighting enum

- PRD: `INDOOR_NATURAL / INDOOR_ARTIFICIAL / OUTDOOR / MIXED`
- Stack: `INDOOR_NATURAL / INDOOR_ARTIFICIAL / OUTDOOR_SHADE / OUTDOOR_DIRECT`

Same field, different CHECK constraint. Sync will fail or lie.

### 2.5 Fitzpatrick + lighting collection

Both schemas **require** these columns. The primary ASHA walkthrough **never asks for them**. No screen, no FR, no default. The AI will either omit the columns (study data dies) or invent a janky form.

### 2.6 Team / stack / dates

- Roadmap roles ≠ PRD roles ≠ “6 Engineers” on the stack doc.
- PRD dated **2025-01-27**. SIH is 2026. Stack pins **Flutter 3.22.0** (May 2024). Current stable is **Flutter 3.44** (May 2026); 3.47 window is this month.
- Stack pins `google_mlkit_face_mesh_detection: ^0.12.0`. **That version does not exist.** Latest on pub.dev is **0.5.0** (2026-07-07). First `flutter pub get` fails.
- Face Mesh plugin is **Android-only, still Beta**. Defense guide talks about Flutter for Android *and* iOS. Fine if you stay Android-only; say so once, everywhere.
- `permission_handler` note mentions **Android 13+ location for Bluetooth linkage**. PRD forbids storing GPS. Why is location in the stack?
- Android 14+ `FOREGROUND_SERVICE` requires a `foregroundServiceType`. Manifest snippet is incomplete.

### 2.7 Whose consent?

Three different rules exist in the same PRD:

1. Exec summary: no consent → screening locked, no camera, no data.
2. Use case step 3: consent on first session of the day **or** first launch.
3. FR-CS.002: before first capture of every session, in study mode.

And it is never nailed whether the consenter is the **ASHA**, the **patient**, or the **volunteer**. For a household visit those are three different people. An AI will build one checkbox and you will have an ethics hole.

---

## 3. Scientific landmines (judges will ask; vibe-coding will hard-code)

### 3.1 Tamir 2017 does **not** give you `a* < 5 / 5–10 / ≥ 10`

Tamir et al., IEEE R10-HTC 2017 ([IEEE 8289053](https://ieeexplore.ieee.org/abstract/document/8289053)):

- n = **19** subjects
- Method: extract conjunctiva, compare **mean Red vs Green in RGB**, plus sclera for brightness normalization
- Result: **15/19 = 78.9%** agreement with blood Hb
- **Not CIELAB. Not a\*. Not those three cutoffs.**

Every doc in this folder cites Tamir as the source of the a* tiers. That is a **mis-citation**. A judge who has read the paper (or Ctrl+F’d the abstract) will treat the rest of the clinical story as untrusted.

Later CIELAB conjunctiva work exists (Dimauro and others). If you want a* you must cite *that* literature — or label the cutoffs as **unvalidated prototype heuristics** and stop saying “literature-derived thresholds.”

### 3.2 Skinopathy arXiv:2603.00161 does **not** give you `b* ≥ 15`

The preprint exists (26 Feb 2026). It is a **React/browser** ophthalmic demo. Icterus is a continuous Yellow Index on **OpenCV-scaled** LAB (`b_cv = b* + 128`), roughly:

`Y_index = clip((b̄* − 128) / (160 − 128), 0, 1)`

That is **not** High ≥ 15 / Moderate 10–15 / Low < 10 in true CIELAB. Citing it as “supporting context” for those exact bins is decorative. Also: it is a 5-month-old prototype in the same idea space. Judges can read it as “you cloned a preprint,” so be ready to say what is *yours* (ASHA workflow, offline-first, Telugu, referral PDF, Indian field constraints).

### 3.3 You are not photographing the palpebral conjunctiva

FR-CA.001 / lean PRD use landmarks:

`Left 33, 133, 159, 145` · `Right 362, 263, 386, 374`

Those are **eye-opening / eyelid-margin** points (outer/inner canthus + mid upper/lower lid). They bound the **visible palpebral fissure** (iris + sclera + lashes).

The **palpebral conjunctiva** is the inner surface of the everted lower lid. It is **not visible** on a resting open eye. Standard anemia photo protocol is: *pull the lower lid down, shoot the inner pink tissue.* Face Mesh on a closed or resting lid will feed the classifier **skin + lash + shadow**, then you will print High/Moderate/Low with a straight face.

This is the single biggest “the app is medically empty” risk. Vibe-coding will implement exactly what you wrote and the ROI will be wrong.

What the spec must add before any coding:

1. Capture choreography: “Ask the patient to look up. Gently pull the lower lid down. Hold 15–20 cm. Fill the ellipse with the inner pink tissue.”
2. Two ROIs from **different** instructions, or two captures:
   - Capture A — everted lid → anemia (a*)
   - Capture B — open eye, temporal sclera → jaundice (b*)
3. Real polygon indices, not a 4-point box:
   - Eye contour (left): `33, 7, 163, 144, 145, 153, 154, 155, 133, 173, 157, 158, 159, 160, 161, 246`
   - Iris ring if available: `468–477` (only with refine / iris model — ML Kit Face Mesh may **not** give iris points; MediaPipe Face Landmarker does)
4. Pixel filters: drop lashes (low L*), drop iris (chroma + circular mask), require **minimum valid pixels** (PRD says 200 for sclera; do the same for conjunctiva).
5. If eversion is too hard for ASHA + neonate: **say so and cut neonatal jaundice**, or use a forehead/chest transcutaneous-style *photo of skin* with a huge limitation banner. Do not pretend Face Mesh on a newborn eye is conjunctival pallor.

### 3.4 Neonatal jaundice + Face Mesh is a product contradiction

AnamoAI positions jaundice as **neonatal** (first 72 hours, kernicterus). ML Kit Face Mesh:

- faces within ~2 m, large in frame, facing camera, ≥ half the face visible
- trained and documented around **adult / child selfie** faces
- newborns: tiny face, often eyes closed, different proportions, parent holding, poor indoor light

You will spend Days 7–9 debugging “no face detected” on the exact population in the problem statement.

**Hackathon-safe scope:** anemia screening in **pregnant / postnatal women** (everted lid). Jaundice as **adult/child scleral icterus**, or a clearly labeled “experimental / neonate not validated” path. Neonatal as v2.

### 3.5 Pulse-ox as Hb ground truth

The long PRD is honest here. Keep that honesty. Do **not** let the short PRD’s “>85% correlation with CIELAB thresholds” sentence survive into the pitch. That sentence is circular (correlate the tool with its own cutoffs) and will sound like clinical accuracy.

### 3.6 White-reference “phone face-down on A4”

Indoor village bulb + no flash + mean RGB ≥ 180 on all channels + channel SD ≤ 15 + <5% clip. That gate will **fail a lot**. It is also a **hard block** (no skip). Field demo risk: the app never reaches the camera.

Need: torch-on option, looser brightness floor for the *reference* (you can still reject color cast), and a documented fallback (“use last-session gains only inside 10 minutes, same room”) *or* accept that the Day 12 volunteer study happens under a window, not a bulb.

---

## 4. What is missing for vibe-coding

Vibe-coding is not “a good PRD.” It is a pack an agent can implement **without inventing UX, strings, or math.** You are missing the pack.

### 4.1 No single instruction file

You need **one** file, something like `VIBE_SPEC.md`, that starts with:

> Ignore every other document. This file wins. If something is not here, ask — do not invent medical copy, thresholds, or schema columns.

Until that exists, every coding session will re-litigate Stack vs PRD.

### 4.2 No screen inventory

Implied screens (not listed as a numbered IA):

1. Language  
2. Home  
3. Consent  
4. Session metadata (Fitzpatrick + lighting) — **missing from flow**  
5. White reference  
6. Capture (AR) — maybe two captures  
7. Repeat-measurement progress — **only in Stack**  
8. Results  
9. PDF name entry  
10. Share sheet  
11. History? (roadmap Day 10; PRD is hostile to stored identity)  
12. Sync status  
13. Settings / language change  
14. Research Mode + PIN — **only in Stack**  
15. Quality-override warning  
16. Consent-decline dead-end  

No wireframe. No component list. No empty / error / offline variants as screenshots or even ASCII.

### 4.3 No design tokens

No hex colors, type scale, icon set, 5-inch result-screen layout that still fits the 12sp locked disclaimer in **Telugu** (longer than English). FR-RD.006 will fail on the first Telugu render and the AI will shrink the disclaimer, which you defined as a **safety defect**.

### 4.4 No string tables

Zero Telugu. Zero Hindi. Disclaimer, six referral actions, consent body, quality-gate coaching, white-ref failures — all unspecified in the shipping languages. `NotoSansTelugu.ttf` is named; the strings it must render are not.

An AI will Google-translate medical safety copy. Do not let it.

### 4.5 No CIELAB implementation contract

PRD says sRGB → linear → XYZ D65 2° → LAB, then **mean** of ROI.

Not specified:

- Exact matrices and the `f(t)` breakpoint  
- Mean vs median vs luminance-weighted mean (Skinopathy weights by L*; you say mean)  
- Per-pixel then average, or average RGB then convert once (FR-AI.005 says convert the **mean**, which is faster and slightly wrong if the ROI is mixed)  
- OpenCV 0–255 LAB vs true LAB (−128..127). **If the coder uses `image` package or a port of OpenCV and you keep thresholds at 5 / 10 / 15, every result is garbage.** This must be a unit-tested function with golden numbers.

Need a 20-line reference implementation + 5 fixture RGB → expected `a*, b*, L*`.

### 4.6 No Laplacian / EAR implementation contract

- Laplacian: kernel size? grayscale method? computed on 100×100 ROI (PRD mitigation) or full frame (lean guide)?
- EAR: you use 4 points. Canonical EAR is 6. Threshold 0.2 is a common *blink* cutoff; an open eye is often 0.25–0.35. Fine, but write the formula and the exact indices.
- Rolling 5-frame exposure mean: specified. Blur flicker: not.

### 4.7 No `pubspec.yaml` that resolves

Minimum you must pin to versions that **exist today**:

```yaml
# illustrative — verify on pub.dev the day you scaffold
environment:
  sdk: ">=3.5.0 <4.0.0"
dependencies:
  flutter_bloc: ^9.0.0          # 8.1.4 is ancient
  camera: ^0.11.0
  google_mlkit_face_mesh_detection: ^0.5.0   # NOT 0.12.0
  google_mlkit_commons: any compatible
  permission_handler: ^11.3.1
  sqflite_sqlcipher: ^3.1.0     # confirm Android 8
  flutter_secure_storage: ^9.2.2
  pdf: ^3.11.0
  printing: ^5.13.0
  share_plus: ^10.0.0
  uuid: ^4.5.0
  path_provider: ^2.1.0
  connectivity_plus: ^6.0.0
  workmanager: ^0.5.2
  flutter_localizations:
    sdk: flutter
  intl: any
```

Plus `flutter: 3.44` or whatever `flutter --version` is on the build machine. Stop writing 3.22.

Also missing from the stack table: `uuid`, `crypto`, `connectivity_plus`, `path_provider`, `printing`, `intl`, `equatable`, `json_annotation`. The AI will add random ones.

### 4.8 Backend is a sketch

You have two endpoints and an UPSERT. Missing:

- `docker-compose.yml` (FastAPI + Postgres)  
- Pydantic models matching **one** schema  
- CORS, TLS, env vars (`JWT_SECRET`, `ORG_CODES`)  
- `GET /health`  
- Admin revoke endpoint (you require it in the go/no-go list)  
- What happens to `captures[]` on conflict  
- OpenAPI file the Flutter client can be generated from  

### 4.9 No test fixtures

No white-reference sample, no everted-lid sample, no sclera sample, no golden LAB table, no “this frame is blurry / this EAR is 0.12” images. Without fixtures, vibe-coded quality gates are theatre.

### 4.10 Consent form, ethics, faculty sign-off

PRD status is still **DRAFT — pending faculty supervisor review**. Phase 1 go/no-go requires a signed consent form. The form is not in this folder.

### 4.11 SIH problem-statement lock

SIH 2026 problem statements roll out July–August 2026. None of these files quote an official **PS ID**, ministry, or constraint list. If you vibe-code a beautiful ASHA anemia app and the PS you get is something else, you will rewrite in a weekend. Lock the PS or keep the architecture generic until it drops.

---

## 5. What *is* good (do not throw it away)

The long PRD is unusually serious for a student hackathon:

- Non-diagnostic rules written as **defects**, not footnotes  
- Locked disclaimer, 12sp, above the fold, three languages  
- Patient name only on PDF, then dropped from memory  
- Offline-first as a hard rule, not a slogan  
- Named limitation on SpO₂ vs moderate anemia  
- n=20 statistical honesty  
- Cut list (sync can be mocked, Hindi can slip, override can die)  
- Edge cases 1–5 are implementable  
- Stack v1.2 correctly fixed: `UNABLE_TO_ASSESS`, split `captures`, algorithm versioning, WorkManager honesty, “don’t bake a key into the APK”

That is *better* than 90% of SIH PRDs. It is still not a vibe-coding pack.

---

## 6. Can you vibe-code *something* tomorrow?

**Yes, a vertical slice — if you freeze this subset and ignore the rest:**

1. Flutter Android app, English-only for Day 5–8  
2. Language stub + fake consent timestamp  
3. Camera preview + ML Kit Face Mesh overlay (ellipse + 4-point EAR)  
4. Quality lights: blur / exposure / EAR  
5. **Manual lid-eversion prompt** + crop inside ellipse  
6. White-patch gains  
7. One LAB conversion function with unit tests  
8. Show **risk labels + disclaimer only** (no a*/b* on ASHA screen)  
9. Save one row to sqflite (unencrypted first; cipher on Day 10)  
10. Generate a one-page PDF and share it  

**Do not vibe-code in the first 48 hours:** device PKI, Research Mode, WorkManager retention, Postgres, Telugu PDF, neonatal path, 3-shot median. Those are how 14-day teams die.

---

## 7. Required freeze before the next coding prompt

Decide these in writing. One line each. Then delete the losing option from every file.

| # | Decision | Recommended freeze for SIH |
|---|---|---|
| D1 | Which doc wins? | Long PRD + a new `VIBE_SPEC.md`. Archive lean PRD as “pitch summary.” |
| D2 | One-shot or 3-shot? | **3-shot / 2-valid / median + UNABLE_TO_ASSESS** if you want study credibility. One-shot if you only need a demo video. |
| D3 | Auth | Device UUID + server token. No APK-baked key. No homemade PKI. |
| D4 | Deletion language | “Eligible at 30 days; deleted on next retention run.” Same sentence in PRD, UI, consent. |
| D5 | Lighting enum | Pick Stack’s four values **or** PRD’s four. Not both. |
| D6 | Who is screened for jaundice? | Cut neonate from v1. Adult/maternal sclera only. |
| D7 | How is conjunctiva captured? | Explicit lid-eversion step. Two captures if needed. |
| D8 | Threshold citation | “Prototype heuristics, not Tamir 2017 cutoffs.” Recite Tamir only as prior RGB work. |
| D9 | Flutter / ML Kit versions | Flutter 3.44 (or machine stable). `google_mlkit_face_mesh_detection: ^0.5.0`. |
| D10 | Languages in demo APK | Telugu + English. Hindi on the cut list. |
| D11 | Consent actor | Patient (or guardian) consent recorded by ASHA. Separate study-consent paper form. |
| D12 | Fitzpatrick / lighting UI | Add a 20-second metadata screen after consent, before white reference. |

---

## 8. Vibe-coding pack still to write (minimum)

If you want an agent to build this without guessing:

1. **`VIBE_SPEC.md`** — frozen decisions + screen list + state machines + schema + API + non-goals  
2. **`design/tokens.md`** — colors, type, 360×800 result-screen ASCII  
3. **`l10n/app_en.arb` + `app_te.arb`** — every worker-facing string, disclaimer locked  
4. **`lib/vision/cielab.dart` spec + golden tests**  
5. **`lib/vision/roi.md`** — capture choreography + polygon indices + min pixel counts  
6. **`pubspec.yaml`** that actually resolves  
7. **`backend/openapi.yaml` + `docker-compose.yml`**  
8. **`fixtures/`** — 5 images + expected scores  
9. **Consent form** (human, not generated into the app)  
10. **Kill list** — files that must not be fed to the coder (lean PRD, defense guide, old stack)

Until 1–8 exist, the answer to “are these enough for vibecoding?” is **no**.

---

## 9. Bottom line

| Question | Answer |
|---|---|
| Are the docs impressive? | The long PRD and Stack v1.2 are. The lean trio is a different, thinner product. |
| Are they perfect? | No. Internal contradictions, a wrong package version, a wrong citation, and an ROI that is not the conjunctiva. |
| Are they complete? | No. No strings, no design, no fixtures, no OpenAPI, no consent form, no SSOT. |
| Enough to vibe-code a demo? | Enough to scaffold. Not enough to ship the product you described. |
| Enough to survive SIH judges? | Only if you fix the Tamir citation, the conjunctiva protocol, the neonate/Face-Mesh clash, and remove “Manus AI” from the defense guide. |

**Do not start a multi-agent coding run on this folder as-is.** You will generate two apps that disagree, and you will not notice until Day 11.
