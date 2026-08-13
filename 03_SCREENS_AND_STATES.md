# 03 — Screens and State Machines

Viewport for all ASCII frames: **360 × 640 dp** (5-inch 720×1280 at 2×). If a frame does not fit this viewport, the design is wrong — do not add a scroll view to S08.

---

## 1. Route table

| ID | Route name | AppBar | Can leave unsaved? |
|---|---|---|---|
| S01 | `/language` | none | n/a |
| S02 | `/home` | none | n/a |
| S03 | `/consent` | close → S02 | yes, no data |
| S04 | `/metadata` | back → discard dialog | dialog |
| S05 | `/white-ref` | back → discard dialog | dialog |
| S06 | `/capture/anemia` | back → discard dialog | dialog |
| S07 | `/capture/jaundice` | back → discard dialog | dialog |
| S08 | `/results` | none (done → S02) | session already saved on entry* |
| S09 | `/pdf` | back → S08 | n/a |
| S10 | `/sync` | back → S02 | n/a |
| S11 | `/settings` | back → S02 | n/a |
| S12 | `/research` | back → S02 | n/a |

\* Persist the screening in the same frame as pushing S08, before the user sees results. If the write fails, stay on a blocking error, do not open S08.

Discard dialog copy: keys `discardTitle`, `discardBody`, `discardConfirm`, `discardCancel`.

---

## 2. Capture state machine

One Bloc: `CaptureBloc`. Two sequential instances of the same machine, parameterised by `Series`.

```
                   ┌─────────────┐
                   │  entering   │
                   └──────┬──────┘
                          ▼
                   ┌─────────────┐
         ┌────────►│  hunting    │◄────────┐
         │         └──────┬──────┘         │
         │                │ gates pass      │ gates fail
         │                ▼                 │
         │         ┌─────────────┐         │
         │         │   ready     │─────────┘
         │         └──────┬──────┘
         │                │ tap
         │                ▼
         │         ┌─────────────┐
         │         │  analysing  │
         │         └──────┬──────┘
         │         valid  │        invalid
         │                ▼            │
         │         ┌─────────────┐     │
         │         │  recorded   │     │
         │         └──────┬──────┘     │
         │                │            │
         │     count<2 and attempts<3  │
         │                ├────────────┘
         │                │
         │     count≥2 and attempts<3
         │                ▼
         │         ┌─────────────┐
         │         │  can_finish │──take more──► hunting
         │         └──────┬──────┘
         │                │ use these
         ▼                ▼
┌─────────────┐    ┌─────────────┐
│  exhausted  │───►│   closed    │
│ (<2 valid)  │    │ (emit risk  │
└─────────────┘    │  or UTA)    │
                   └─────────────┘
```

| State | Capture button | Lamps |
|---|---|---|
| hunting | disabled | each red/green |
| ready | enabled, primary | all green |
| analysing | hidden, spinner | frozen |
| recorded | hidden, check | — |
| can_finish | “Use these” primary, “Take one more” text | — |
| exhausted | none, auto-advance after 800 ms | — |
| closed | — | — |

Invalid attempt increments `attempts`, stores a `captures` row with `valid=0` and a `rejection_reason`, returns to hunting if `attempts < 3`.

---

## 3. Session Bloc

```
idle → consenting → metadata → calibrating → anemia_series
     → jaundice_series → persisting → done
```

Any `discard` event from S04–S07 → `idle` and a new `screeningId` next time.

---

## 4. Screen specifications

### S01 — Language

**Purpose.** Choose UI language once.

```
┌────────────────────────────────────┐
│                                    │
│         [ official lockup ]        │
│     V + leaf-pulse + vytra         │
│        AI HEALTH SCREENING         │
│     See Health. Detect Early.      │
│                                    │
│     ┌──────────────────────────┐   │
│     │        తెలుగు            │   │
│     └──────────────────────────┘   │
│     ┌──────────────────────────┐   │
│     │        हिन्दी             │   │
│     └──────────────────────────┘   │
│     ┌──────────────────────────┐   │
│     │        English           │   │
│     └──────────────────────────┘   │
│                                    │
│   A screening aid. Not a diagnosis.│
└────────────────────────────────────┘
```

Use `assets/brand/vytra_logo_lockup.png`. Do not typeset a second wordmark.

- Full-width buttons, 56 dp, icon none.
- Footer uses English on first launch (no locale yet). After a choice, S01 is not shown again unless opened from S11.

### S02 — Home

```
┌────────────────────────────────────┐
│ VYTRA                         ⚙     │
│ See Health. Detect Early.          │
│                                    │
│  ┌──────────────────────────────┐  │
│  │                              │  │
│  │     [ large plus / eye ]     │  │
│  │      New screening           │  │
│  │                              │  │
│  └──────────────────────────────┘  │
│                                    │
│  Works without internet · v1.0.0   │
└────────────────────────────────────┘
```

- Primary CTA only for screening. No patient list. No sync badge.
- If `SECONDARY_TOOLS=true`, a text link **More tools** sits under the CTA (not a second big button).
- Gear → S11.
- Five taps on `v1.0.0` → PIN sheet → S12.
- Subtitle `homeOfflineReady` is constant, even when online.

### S03 — Consent

```
┌────────────────────────────────────┐
│  ✕  Consent                        │
│                                    │
│  (scrollable body, 16 sp, 1.4)     │
│  Purpose, what is stored, 30-day   │
│  eligibility, no name, no photo,   │
│  right to refuse.                  │
│  Verbatim from 07_LOCALIZATION.    │
│                                    │
│ ┌──────────────┐ ┌───────────────┐ │
│ │   Decline    │ │    I agree    │ │
│ └──────────────┘ └───────────────┘ │
└────────────────────────────────────┘
```

- Agree is filled primary. Decline is outlined.
- Body **is** allowed to scroll. Buttons are pinned.
- Do not pre-tick anything.

### S04 — Session metadata

```
┌────────────────────────────────────┐
│  ←  About this visit               │
│                                    │
│  Skin tone (Fitzpatrick)           │
│  [I][II][III][IV][V][VI]           │
│  each a labelled swatch            │
│                                    │
│  Who chose the tone?               │
│  ( ) Person said   ( ) I assessed  │
│                                    │
│  Light right now                   │
│  [ Indoor window ]                 │
│  [ Indoor bulb   ]                 │
│  [ Outdoor shade ]                 │
│  [ Outdoor sun   ]                 │
│                                    │
│         [ Continue ]               │
└────────────────────────────────────┘
```

- Continue disabled until all three are set.
- Swatches must be distinguishable in greyscale (add Roman numerals).

### S05 — White reference

```
┌────────────────────────────────────┐
│  ←  Set the light                  │
│                                    │
│  ┌──────────────────────────────┐  │
│  │                              │  │
│  │     live rear preview        │  │
│  │     dashed rectangle         │  │
│  │                              │  │
│  └──────────────────────────────┘  │
│                                    │
│  Hold the phone above a plain      │
│  white paper. Fill the box.        │
│                                    │
│  (guidance appears on failure)     │
│                                    │
│  🔦          ( ● capture )         │
└────────────────────────────────────┘
```

Failure messages (one or more):

| Code | Key |
|---|---|
| dark | `whiteRefFailDark` |
| cast | `whiteRefFailCast` |
| clip | `whiteRefFailClip` |

### S06 — Anemia capture

```
┌────────────────────────────────────┐
│  ←  Inner eyelid          1 / 3    │
│                                    │
│  ┌──────────────────────────────┐  │
│  │         ╭──────╮             │  │
│  │         │ pink │  ellipse    │  │
│  │         ╰──────╯             │  │
│  │                              │  │
│  └──────────────────────────────┘  │
│  ▓ blur   ▓ light                 │
│  Pull the lower lid down. Fill     │
│  the ring with the inner pink.     │
│                                    │
│            ( ● )  disabled/ready   │
└────────────────────────────────────┘
```

- Counter = attempts so far + 1, max 3.
- Two lamps only.
- Coaching text swaps per failed lamp (`captureHoldStill`, `captureBrighter`, `captureLessSun`).
- After 2 valid: replace shutter with `Use these` + `Take one more`.

### S07 — Jaundice capture

Same chrome as S06 with three lamps (blur, light, eye open) and copy `captureScleraCoach`. Temporal half of the ellipse is drawn with a thicker arc so the worker aims at the outer white.

### S08 — Results

**This screen is a layout acceptance test.** Telugu disclaimer must still fit.

```
┌────────────────────────────────────┐
│  Screening result                  │
│                                    │
│  ┌ HIGH-URGENCY BANNER (if HIGH) ┐ │
│  │ Refer to the PHC today        │ │
│  └───────────────────────────────┘ │
│                                    │
│  ┌────────────┐  ┌────────────┐    │
│  │  ▲ shape   │  │  ● shape   │    │
│  │  Anemia    │  │  Jaundice  │    │
│  │  High risk │  │  Low risk  │    │
│  │  Blood     │  │  Routine   │    │
│  │  test today│  │  watch     │    │
│  └────────────┘  └────────────┘    │
│                                    │
│  This screening result is not a    │
│  medical diagnosis. It is a triage │
│  aid for trained health workers    │
│  only. All results require         │
│  confirmation by a qualified       │
│  medical professional. Do not make │
│  treatment decisions based on this │
│  result alone.                     │
│                                    │
│  [ Generate PDF ]   [ Done ]       │
└────────────────────────────────────┘
```

| Class | Shape (colour-blind safe) | Fill |
|---|---|---|
| HIGH | triangle | `#B42318` |
| MODERATE | diamond | `#B54708` |
| LOW | circle | `#027A48` |
| UNABLE_TO_ASSESS | square with dash | `#475467` |

Banner fill `#7A271A` on `#FEF3F2`, 14 sp, only if either class is HIGH.

Unable tile action: `actionUnable` (“This part could not be read. Refer if you are unsure.”). No silent `LOW`.

### S09 — PDF

```
┌────────────────────────────────────┐
│  ←  Referral note                  │
│                                    │
│  Name or household number          │
│  (optional)                        │
│  [____________________________]    │
│                                    │
│  This name is written on the PDF   │
│  only. It is not saved in the app. │
│                                    │
│         [ Create PDF ]             │
└────────────────────────────────────┘
```

On success, open the system share sheet immediately. Then pop to S08. Clear the text controller in `dispose`.

### S10 — Sync status

List of local screenings: date/time, two class chips, status chip. No names (there are none). Pull-to-refresh triggers a sync attempt if connected; if offline the chips stay Pending with no toast about internet.

### S11 — Settings

- Language (te / hi / en) — applying rebuilds `MaterialApp.locale`
- Open-source licences
- Version + `algorithm_version` + `threshold_version` in small print
- No account, no logout, no server URL field in the study flavour

### S12 — Research

PIN first. Then last screening: a\*, b\*, L\*, per-capture scores, versions, device, Fitzpatrick, lighting, valid counts. Labelled “Research view — do not show the patient.”

### S13–S20 — More tools (skin / teeth)

Optional. Only if `SECONDARY_TOOLS=true`. Full spec: `11_SECONDARY_MODULES.md`.

- S13 hub with two experimental tiles and an internet warning
- S14–S16 skin (third-party consent → capture → result + ABCDE)
- S17–S19 teeth (third-party consent → capture → score)
- S20 static ABCDE education

Do not design these as large as the home CTA. Do not put their results on the ASHA PDF.

---

## 5. Iconography (must exist before UI implementation)

Provide SVG in `assets/icons/` with these exact filenames:

| File | Meaning |
|---|---|
| `icon_new_screening.svg` | Home CTA |
| `icon_risk_high.svg` | triangle |
| `icon_risk_moderate.svg` | diamond |
| `icon_risk_low.svg` | circle |
| `icon_risk_unable.svg` | dashed square |
| `icon_lamp_ok.svg` / `icon_lamp_bad.svg` | quality lamps |
| `icon_lid.svg` | anemia series |
| `icon_sclera.svg` | jaundice series |
| `icon_paper.svg` | white reference |
| `icon_pdf.svg` | generate PDF |

If SVGs are missing, use Material outlined icons as a temporary stand-in, but keep the **shapes** for risk (triangle/diamond/circle/square). Never ship HIGH and LOW as two red/green circles.

---

## 6. Motion

- Screen transitions: default Material.
- Capture shutter: 120 ms scale.
- No celebration confetti on LOW. No alarm animation on HIGH beyond the static banner.
- Reduce motion: honour `MediaQuery.disableAnimations`.
