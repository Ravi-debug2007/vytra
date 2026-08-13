# PRODUCT REQUIREMENTS DOCUMENT
## AnamoAI — Optical Screening Tool for Anemia and Neonatal Jaundice

**Document Version:** 1.0
**Status:** DRAFT — Pending faculty supervisor review
**Date:** 2025-01-27
**Owner:** Project Lead
**Review cycle:** This document is the single source of truth. Any change to scope, thresholds, or constraints must be recorded here with a dated note. Changes to the disclaimer text, data retention rules, or consent flow require Project Lead sign-off and must be reflected in the consent form before the next volunteer session.

---

## TABLE OF CONTENTS

1. Executive Summary
2. Problem Statement
3. Success Metrics
4. Team Structure and Ownership
5. Users and Use Cases
6. Functional Requirements
7. Non-Functional Requirements
8. Technical Architecture
9. Constraints and Known Limitations
10. Out of Scope — Version 1
11. Phased Implementation Plan
12. Open Questions and Decisions Required
13. References and Dependencies

---

## 1. EXECUTIVE SUMMARY

### What This Product Is

AnamoAI is an offline-first Android application that uses smartphone camera optics and CIELAB colorimetric analysis to screen for anemia and neonatal jaundice at the point of care during ASHA worker household visits. It is a non-diagnostic triage aid, not a medical device.

### Who It Is For and In What Context

The primary user is an ASHA (Accredited Social Health Activist) worker conducting household visits in rural or semi-urban India, operating on an NHM-issued or personal low-end Android device, frequently without internet connectivity, often in ambient or low-light indoor conditions, and under time pressure. The secondary consumer of its output is a PHC (Primary Health Centre) Medical Officer who receives a printed or digitally shared PDF referral report and makes the decision to confirm or dismiss the screening result using clinical tools.

### The Problem It Solves and the Consequence When It Goes Unsolved

ASHA workers currently have no point-of-care tool to flag anemia in pregnant women or jaundice in neonates during household visits. Clinical blood tests require facility referral. The absence of any pre-referral screening means that visually detectable anemia and jaundice go unrecorded until the patient self-presents at a facility — which may not happen. Undetected moderate-to-severe anemia in pregnancy contributes to low birth weight, preterm birth, and maternal mortality. Missed neonatal jaundice within the first 72 hours of life can progress to kernicterus and permanent neurological damage. The consequence of an unsolved problem is not a delayed data point — it is a preventable death or disability.

### Why This Technical Approach and Not Another

CIELAB colorimetric analysis of the conjunctiva and sclera using the device's built-in rear camera requires no additional hardware, no consumables, no per-test cost, and no internet connectivity at the time of use. Alternative approaches — pulse oximetry requires a physical device the ASHA worker may not carry; near-infrared spectroscopy requires specialized hardware; facility-based hemoglobin testing requires the patient to travel. A smartphone camera is hardware the ASHA worker already has. CIELAB conversion is mathematically deterministic and runs entirely on-device without a cloud model inference call. This is the only approach that satisfies the zero per-test cost constraint, the offline-first constraint, and the existing hardware constraint simultaneously.

### Regulatory and Ethical Positioning — Operational Rules

These are not aspirations. They are implementation requirements. Any screen, string, or PDF that violates these rules is a defect, not a design choice.

**What the app will never claim on any screen:**

- "This result is accurate."
- "This result is a diagnosis."
- "Your hemoglobin level is [value]."
- "Your bilirubin level is [value]."
- "No further testing is required."
- Any numerical CIELAB value presented to the ASHA worker or the patient.
- Any comparison to clinical diagnostic thresholds presented as equivalence.
- "FDA approved," "clinically validated," "CE marked," or any regulatory certification claim.

**What every result screen must display verbatim:**

> "This screening result is not a medical diagnosis. It is a triage aid for trained health workers only. All results require confirmation by a qualified medical professional. Do not make treatment decisions based on this result alone."

This text must appear in full. It must appear in the active language (Telugu, Hindi, or English). It must not be truncated, collapsed behind a toggle, placed below a scroll fold, or rendered in a font size smaller than 12sp. Compliance is verified at 100% of result screen renders. This is a safety metric, not a UX decision.

**What happens to data at 30 days:**

Each individual screening record is automatically and permanently deleted from local device storage exactly 30 calendar days from the date of that specific capture — not from the study end date, not from app installation date. Deletion requires no action from the ASHA worker. Deletion is irreversible. Any record synced to the backend follows the backend's independent deletion schedule, which must be defined before the volunteer study begins and must be communicated to volunteers in the consent form. The 30-day clock starts at the moment of capture, per-record.

**What the app does if a user has not given consent:**

The app does not proceed. The screening flow is inaccessible. No data is collected. No camera is activated. The app displays a single screen explaining that consent is required to use the screening function, with an option to return to the consent screen or exit the app. No partial session is created. No consent refusal is logged.

---

## 2. PROBLEM STATEMENT

### The Specific Problem Being Solved

There is no low-cost, hardware-free, offline-capable screening tool that an ASHA worker can use during a household visit to flag probable anemia in a pregnant woman or probable jaundice in a neonate — before the point at which clinical confirmation becomes possible. The gap is not in clinical diagnosis; it is in the pre-referral triage decision. Without a triage signal, referral is based on subjective visual assessment, which is inconsistent, undocumented, and non-transferable to the receiving clinician.

### Who Experiences It and In What Physical Context

The ASHA worker is the primary problem-bearer. She is conducting a household visit, often in a rural or peri-urban home with variable ambient lighting — natural light through a window, a single bulb, or outdoor light if the visit occurs on a veranda. She carries a low-end Android phone, a paper register, and a supply kit. She has limited time per household. She may have functional literacy in Telugu or Hindi but limited English. She is not trained in clinical interpretation. She cannot draw blood. She cannot use a laboratory instrument. She needs to make a binary decision — refer or do not refer — and she needs something to back that decision when she hands the patient a referral slip.

**The physical conditions of use are:**

- Indoor ambient or low natural light, frequently variable within a single visit
- Outdoor use possible on verandas or open courtyards
- Device in hand, patient seated or lying — no tripod, no controlled imaging environment
- No reliable internet connectivity during the visit; 2G may be available intermittently; 4G is not assumed
- Shared or personal device; multiple ASHA workers may share one NHM-issued device in some blocks
- Time pressure: household visit is typically 20–40 minutes covering multiple health tasks; the worker cannot spend 10 minutes on a single screening

### Downstream Clinical Consequences When This Problem Goes Unsolved

**Undetected anemia in pregnant women:** Moderate anemia (hemoglobin 8–10.9 g/dL) in the second and third trimesters is associated with low birth weight, preterm delivery, and increased risk of maternal hemorrhage during delivery. Severe anemia (hemoglobin < 8 g/dL) is directly associated with maternal mortality. Without a pre-referral flag, a moderately anemic woman who feels "tired but functional" has no reason to self-present at the PHC and the ASHA worker has no documented basis to escalate. She is not referred. Her condition progresses.

**Missed neonatal jaundice:** Neonatal jaundice caused by hyperbilirubinemia is common and treatable with phototherapy if detected within the first 72–96 hours of life. Jaundice visible in the sclera represents a bilirubin level that may already be at or approaching the threshold for intervention. Without detection during the postnatal household visit — typically the only clinical contact a home-delivered neonate has in the first week — the window for phototherapy closes. Progression to severe hyperbilirubinemia causes bilirubin encephalopathy (kernicterus), resulting in permanent neurological damage, cerebral palsy, or death. This is not a statistical abstraction. It is a time-constrained clinical emergency presenting as a yellow-eyed baby in a village home.

**Delayed referral leading to preventable hospitalization:** Even in cases that do not reach the most severe outcomes, delayed detection means delayed referral, which means the patient arrives at the PHC with a more advanced condition requiring more intensive intervention. Hospitalization that could have been avoided with early ambulatory treatment consumes district health resources, removes a patient from their household, and is associated with worse outcomes for both the patient and their dependents.

### The Full Constraint Set

**Connectivity:**
No reliable internet during use. The app must function completely offline for all core screening functions. Sync to backend is a post-hoc operation that occurs when connectivity is available. No core function may depend on connectivity. No error state in the screening flow may be caused by absence of internet.

**Device:**

- Minimum: Android 8.0 (API level 26)
- Minimum camera: 8MP rear camera
- Reference device for performance targets: Snapdragon 665 processor, 4GB RAM
- The app must not require a flagship device. It must work acceptably on the reference device. It must degrade gracefully, not crash, on lower-spec devices.
- APK sideloading is the expected distribution method — the app will not be on the Play Store for the study period.

**Literacy:**
The primary user may have limited English literacy. Telugu and Hindi are the priority languages. The UI is icon-driven as a primary pattern. Text labels are secondary to iconography. No screen in the core screening flow should be navigable only through English text.

**Cost:**
Zero per-test cost is a hard constraint. No consumable. No hardware attachment. No cloud inference call per screening. No per-query API cost. The app uses the device's built-in camera and runs all analysis locally.

**Regulatory — Non-Diagnostic Screening Tool:**
This is a defined operational status, not a disclaimer. It means specifically:

**What the app will do:**

- Compute a colorimetric signal from the conjunctiva and sclera
- Compare that signal to literature-derived thresholds
- Return a risk classification (High / Moderate / Low) for anemia and jaundice
- Display a referral recommendation in plain language
- Generate a PDF referral document for the receiving clinician
- Log the screening event locally and sync anonymized aggregate data to a study backend

**What the app will not do:**

- Report a hemoglobin value, a bilirubin concentration, or any numerical clinical measurement
- Claim to diagnose any condition
- Recommend a specific treatment
- Substitute for clinical laboratory testing
- Be used as the sole basis for any clinical decision
- Claim performance equivalence with any approved diagnostic device
- Function as a medical device under any regulatory framework

---

## 3. SUCCESS METRICS

### Performance Metrics

| Metric | Target | Measurement Condition | Pass / Fail |
|--------|--------|----------------------|-------------|
| AR guidance frame rate | ≥ 20 FPS | Snapdragon 665, 4GB RAM, indoor ambient light | Hard pass/fail |
| Classification latency | < 3 seconds | From capture confirmation to result display | Hard pass/fail |
| PDF generation time | < 5 seconds | From worker tapping "Generate PDF" to file available for share | Hard pass/fail |
| App cold start | < 4 seconds | From icon tap to language selection screen rendered | Hard pass/fail |
| Battery consumption per full session | < 2% | Full session: language select → consent → white reference → capture → result → PDF; Reference device | Hard pass/fail |
| Medical disclaimer display rate | 100% | Every render of a result screen, in every language | Safety metric — any failure is a critical defect |
| Screening accuracy | > 85% correlation with literature-derived CIELAB thresholds on the reference image set | Pearson r against ground truth hierarchy | Feasibility target |

**Note on the disclaimer display rate metric:** This is not a UX acceptance criterion. It is a safety requirement. A result screen rendered without the full disclaimer text in the active language is a defect of the same severity as a result screen showing an incorrect risk classification. It must be tested explicitly as part of every build's test suite, not assumed to pass.

### Validation Methodology

**Sample:**
n=20 volunteers. This sample size provides the following statistical properties and the following properties only:

- With Pearson r > 0.7, α = 0.05, two-tailed, and power = 0.80, a minimum n of approximately 19 is required. n=20 is minimally adequate to detect a large correlation under these parameters.
- This sample is **not** powered to detect a moderate correlation (r ≈ 0.5).
- This sample is **not** powered to establish clinical diagnostic accuracy at any confidence level appropriate for regulatory submission.
- This sample **cannot** support subgroup analysis — results cannot be reported separately by skin tone category or trimester with any statistical validity at this n.
- This sample **cannot** support generalizability claims beyond the specific volunteer cohort.
- Any language in any output from this project — presentation, paper, pitch deck, or abstract — that implies this study proves clinical accuracy is factually incorrect. The study proves feasibility of the method. Nothing more.

**Ground Truth Hierarchy:**

- **First choice:** Clinic-recorded hemoglobin (g/dL) from hemoglobinometer or complete blood count for anemia; clinic-recorded bilirubin (mg/dL) from transcutaneous bilirubinometer or serum bilirubin for jaundice. These records must be obtained within 48 hours of the screening session to be considered valid ground truth. The process for obtaining these records from PHC partners must be confirmed before Day 8 (study execution start).

- **Second choice (proxy):** Pulse oximetry SpO₂ reading as a proxy for hemoglobin level, where clinic records are unavailable. This is the expected fallback for the majority of the n=20 sample.

**NAMED LIMITATION — MODERATE ANEMIA TIER VALIDATION:**

This limitation is named here and must be referenced explicitly in the study report, the pitch deck, and any summary of findings. It is not a footnote.

Pulse oximetry (SpO₂) is an unreliable proxy for moderate anemia. SpO₂ remains in the normal range (95–100%) until hemoglobin drops to approximately 7–8 g/dL, which corresponds to severe anemia. A volunteer with a hemoglobin of 9 g/dL — classified as Moderate Risk by this tool — will typically show a normal SpO₂ reading. This means the pulse oximetry proxy cannot confirm or refute a Moderate Risk anemia classification. As a consequence:

- High Risk tier anemia results have ground truth support from pulse oximetry proxy (severe anemia is detectable by SpO₂ depression) and, where available, from clinic hemoglobinometer records.
- Moderate Risk tier anemia results have materially weaker ground truth validation when clinic records are unavailable.
- The study report must present moderate-tier anemia accuracy with an explicit statement that ground truth was not available from pulse oximetry and that the accuracy figure at this tier is indicative only.
- The decision of whether to report moderate-tier accuracy separately or collapse to a binary High / Not-High classification for the validation analysis is an open decision documented in Section 12, Q1.

**Statistical Approach:**

- Primary metric: Pearson r between the tool's a* and b* values (or their derived risk classifications mapped to an ordinal scale) and ground truth hemoglobin / bilirubin values
- Target: Pearson r > 0.7
- Significance level: α = 0.05, two-tailed
- Power: 0.80
- Confidence intervals: 95% CI reported for all correlation coefficients
- No result is reported without its confidence interval

**Confounders to be Logged at Session Time:**

All of the following must be recorded in the local database at the time of each screening session and included in any sync payload:

- Skin tone: Fitzpatrick scale category (I–VI), self-reported by volunteer or assessed by the project lead. The assessment method (self-report vs. worker-assessed) must itself be logged, as it affects reliability.
- Device model: Captured programmatically from device metadata; not entered manually.
- Ambient lighting condition: Logged as a categorical field with options — Indoor Natural Light / Indoor Artificial Light / Outdoor / Mixed. Entered by the worker or study administrator at session start. Not inferred algorithmically in v1.

**What the Study Will Prove:**

Feasibility of CIELAB-based optical screening for anemia and jaundice indicators on Indian skin tones using consumer Android hardware in a field-simulated setting, with n=20 volunteers under research conditions.

**What the Study Will Not Prove:**

- Clinical diagnostic accuracy of the tool for any condition
- Performance equivalence with any approved diagnostic device
- Generalizability of results beyond the specific volunteer cohort
- Performance under the full range of field conditions (lighting, device diversity, operator variability at scale)
- Safety or efficacy for regulatory submission under any framework
- Statistical performance in subgroups defined by skin tone, age, trimester, or device model

---

## 4. TEAM STRUCTURE AND OWNERSHIP

### Team Members and Roles

| Role | Primary Responsibility | Section 11 Workstream Assignments |
|------|----------------------|-----------------------------------|
| Flutter Developer 1 | Mobile frontend, navigation, UI implementation, camera pipeline integration | Flutter scaffold, navigation, AR capture pipeline, quality gate integration, result display, PDF export, localization implementation |
| Flutter Developer 2 | Local storage, encryption, sync client, offline queue | sqflite schema, AES-256 encryption, sync queue, offline state management, database deletion logic |
| ML/CV Engineer | CIELAB analysis, MediaPipe integration, quality gate algorithms, classification logic | MediaPipe face mesh PoC, ROI extraction, white-patch normalization, CIELAB conversion, threshold classification |
| Backend Developer | FastAPI server, PostgreSQL schema, authentication, sync endpoint | FastAPI skeleton, API key auth, sync endpoint, PostgreSQL schema, backend deletion schedule |
| UI/UX Designer | Wireframes, AR overlay design, localization layout, icon system | Wireframes for all screens, AR overlay visual design, icon set, Telugu/Hindi layout validation |
| Project Lead | PRD, pitch deck, volunteer coordination, ethics logistics, documentation | PRD authorship, pitch deck, consent form drafting, faculty supervisor liaison, ethics clearance tracking, localization string coordination |

**Ownership rule:** Every workstream in Section 11 is assigned to exactly one of the roles in this table. No workstream is assigned to a role not listed here. If a workstream requires collaboration, it has a primary owner and a named supporting role. The primary owner is accountable for the workstream being done. The supporting role is accountable for their specific contribution.

---

## 5. USERS AND USE CASES

### User 1: ASHA Worker (Primary Field User)

**Who they are and what context they operate in:**
An Accredited Social Health Activist operating under the National Health Mission, conducting household visits in rural or semi-urban India. She visits pregnant women, postnatal mothers, and neonates. She carries a low-end Android device — either personally owned or NHM-issued. She is in a patient's home, which may be a single-room dwelling with limited lighting. She has limited time. She has functional literacy in Telugu or Hindi; her English literacy may be limited to recognizing common words and numbers. She is not a clinician.

**Her goal when using the product:**
To complete a screening of the patient's conjunctiva (anemia) and sclera (jaundice) in under three minutes, receive a clear risk classification with a plain-language referral recommendation, and leave the household with a PDF that documents the screening result for the receiving clinician.

**What she must never be asked to do:**

- Interpret a raw CIELAB value or any numerical output from the analysis
- Make a clinical judgment about the result
- Choose between competing diagnoses
- Enter medical terminology
- Navigate an English-only interface
- Perform any action to sync data to the cloud
- Manually delete expired records

**Her specific technical constraints:**

- Device: Android 8.0 minimum, 8MP rear camera minimum, Snapdragon 665 class or lower
- Connectivity: zero connectivity during field use; sync occurs opportunistically
- Literacy: Telugu or Hindi as primary language; icon-first navigation
- Time: screening must be completable in under 5 minutes including PDF generation

### User 2: PHC Medical Officer (Receives PDF Reports)

**Who they are and what context they operate in:**
A physician or senior health officer working at a Primary Health Centre. They receive referred patients from ASHA workers. When a patient presents following a referral, the medical officer receives the printed or digitally shared PDF that the ASHA worker generated.

**Their goal when using the product:**
They do not use the app. They use the PDF. The PDF must contain enough structured information to allow the medical officer to triage the patient without asking the ASHA worker follow-up questions and without needing to understand how the app works. The medical officer is skeptical of technology claims by training and professional instinct. The disclaimer on the PDF must be prominent enough that the medical officer sees it as a serious document produced by a system that knows its own limitations, not as a marketing artifact.

**What they must never be asked to do:**

- Install the app
- Create an account
- Interpret CIELAB values
- Trust the result without clinical confirmation — the disclaimer is a feature for this user, not a concession

**Their specific technical constraints:**

- Receives PDF via WhatsApp, printed paper, or email
- May be using any device or no device — the PDF must be readable in print
- No interaction with the app or backend

### User 3: District Health Programme Manager (Views Aggregate Sync Data)

**Who they are and what context they operate in:**
A district-level public health official responsible for monitoring ASHA worker coverage, referral rates, and screening programme performance across multiple PHC catchment areas.

**Their goal when using the product:**
To view aggregate, anonymized screening counts, referral rates by risk tier, and geographic coverage — without accessing any individual patient data.

**What they must never be asked to do:**

- Access individual patient records
- Use the Android app

**Their specific technical constraints:**

- Accesses data via a web dashboard or exported CSV from the backend
- This is a SHOULD HAVE for v1, not a MUST HAVE. If the 14-day timeline is at risk, this feature is the first to be deferred.
- See Section 11 for cut priority decisions.

---

### Primary Use Case: ASHA Worker Household Visit — Numbered Scenario

**Start:** ASHA worker opens the app at a household visit.
**End:** She hands a printed or shared PDF to the patient or their family member.

1. ASHA worker opens the app. App cold-starts in under 4 seconds and displays the language selection screen.
2. Worker selects Telugu (or previously selected language loads automatically from stored preference).
3. If this is the first session of the day or the first time the app has been opened on this device, the consent screen is displayed. If consent has already been recorded for this session type, proceed to step 6.
4. Worker reads or receives a read-aloud of the consent screen content (purpose of screening, data storage for 30 days, anonymization, right to refuse). Consent screen is displayed in the active language.
5. Worker confirms consent by tapping the consent confirmation control. Consent is recorded locally with a timestamp. If the patient (or worker acting as their proxy) declines consent, the app returns to the home screen with no data saved and the screening flow is inaccessible.
6. App prompts the worker to capture a white reference image. On-screen instruction reads (in active language): "Place the phone face-down on a white sheet of paper and tap capture" — or equivalent icon-driven instruction validated by the UI/UX designer.
7. Worker captures white reference image. App assesses the image for validity: mean pixel intensity of the captured image must be ≥ 180 in all three RGB channels; standard deviation across channels must be ≤ 15 (indicating neutral color); image must not be overexposed (no channel clipped at 255 for more than 5% of pixels). If valid, gains are calculated and stored in the session object. If invalid, specific corrective guidance is shown (see FR-WR.003). Worker may retry.
8. White reference validated. App displays a success confirmation and advances to the capture screen.
9. Face mesh tracking initializes. The AR overlay appears on the camera preview, showing a positioning guide — a translucent ellipse indicating where the patient's eye should appear in frame, with directional arrows if alignment is off.
10. Worker positions the device camera approximately 15–20 cm from the patient's eye, as guided by the AR overlay.
11. Quality gate evaluates each live frame continuously. Three indicators are visible to the worker using icon-based status signals (not text-based pass/fail): blur level, exposure level, and eye openness. Each indicator changes from inactive to active as its gate passes.
12. When all three gates pass simultaneously — Laplacian variance > 100, mean pixel intensity 40–200, and Eye Aspect Ratio > 0.2 — the capture button activates and becomes tappable. The worker taps the capture button.
13. Image is captured. ROI for conjunctiva (lower palpebral conjunctiva, identified from face mesh landmarks) and ROI for sclera (visible white area of the eye, identified from face mesh landmarks) are extracted from the captured frame.
14. White-patch gains from step 7 are applied to both ROIs.
15. CIELAB conversion is performed on both ROIs. a* value is computed for the conjunctival ROI. b* value is computed for the scleral ROI.
16. a* value is compared to anemia thresholds. b* value is compared to jaundice thresholds. Risk classifications are generated: Anemia risk — High / Moderate / Low. Jaundice risk — High / Moderate / Low.
17. Classification completes in under 3 seconds from capture confirmation.
18. Result screen is displayed. Both classifications are shown simultaneously on one screen. Each classification is represented by a color-coded icon (red / amber / green) with a text label in the active language. Recommended next action is shown for each in plain language.
19. The mandatory disclaimer is displayed in full on the result screen in the active language, in a minimum 12sp font, above the scroll fold, not behind a toggle.
20. If either result is High Risk: a specific referral instruction appears in prominent display (e.g., "Refer to PHC today" in active language). The referral instruction is distinct from the risk label — it is an action, not a classification.
21. Worker taps "Generate PDF." App displays the PDF generation screen.
22. PDF generation screen prompts worker to enter a patient reference — name or household ID. This is the only moment a patient identifier enters the system. Worker enters the reference using the on-screen keyboard.
23. Worker taps "Generate." PDF is generated locally in under 5 seconds. The patient reference entered in step 22 is written into the PDF header. After PDF generation is complete, the patient reference string is discarded from memory. It is not written to the local database. It is not included in any sync payload.
24. App displays the Android share sheet. Worker selects WhatsApp, share via Bluetooth, or any other sharing option to send the PDF to the patient, a family member's phone, or the receiving clinician.
25. Result is written to the local encrypted database. Sync queue is updated. Sync occurs automatically when connectivity is available — no worker action required.
26. Worker exits the screening session. Session is complete.

---

### Edge Case 1: Quality Gate Fails Three Times

1. Worker positions device for capture. Quality gate evaluates the frame.
2. First failure: One or more gates fail. The gate status indicator shows which gate(s) have not passed. Specific guidance appears:
   - **Blur failure** (Laplacian variance ≤ 100): "Hold the phone steady and move slightly closer to the eye."
   - **Exposure failure — too dark** (mean intensity < 40): "Move to a brighter area or turn on the screen light."
   - **Exposure failure — too bright** (mean intensity > 200): "Move away from direct sunlight or cover the light source."
   - **Eye openness failure** (EAR ≤ 0.2): "Ask the patient to open their eye wider and look straight ahead."
   - If multiple gates fail simultaneously, all applicable guidance messages are shown — one per failed gate, not a combined generic message.
3. Second failure: Same guidance is shown. No escalation yet. Worker retries.
4. Third consecutive failure: App shows a modal dialog with two options:
   - **Option A:** "Try again" — returns to camera with guidance still displayed.
   - **Option B:** "Continue without quality check" — manual override.
5. If worker selects Option B (manual override):
   - A warning screen is displayed before capture proceeds: "This image has not passed quality checks. The result may be less reliable. This will be noted in the report." Worker must confirm explicitly by tapping a confirmation control — not by tapping "Continue" ambiguously.
   - Capture proceeds.
   - The result is flagged in the local database field `quality_override: true`.
   - The PDF generated from this session contains the text: "Note: This result was captured without passing all image quality checks. Reliability may be reduced."
   - The sync payload includes `manual_override: true`.
6. If worker selects Option A again and continues to fail: the options reappear each time the worker attempts capture after three cumulative consecutive failures. The app does not lock the worker out indefinitely. The override option remains available.

### Edge Case 2: Patient Refuses Eye Photograph

1. Worker has opened a session and reached the capture screen. Patient declines to have their eye photographed.
2. Worker taps the back/exit control on the capture screen.
3. App displays a confirmation dialog: "Discard this screening session? No data will be saved." Dialog has two options: "Discard session" and "Return to capture."
4. Worker taps "Discard session."
5. Any in-progress session data — quality gate log, partial results, session ID — is discarded from memory. Nothing is written to local storage.
6. App returns to the home screen.
7. No partial result exists. No record of the refused session exists on-device.

**Note:** The worker is not prompted to record the reason for refusal in v1. This is intentional — recording a reason requires the worker to make a judgment about the patient's decision and creates a data record about a person who did not consent. This is excluded by design, not omission.

### Edge Case 3: Device Goes Offline Mid-Sync

1. Worker completes a screening session. Result is written to local encrypted database immediately on session completion, before any sync attempt.
2. Sync client detects connectivity and attempts to push the sync payload to the backend.
3. Mid-sync, connectivity drops. The sync request fails or is interrupted.
4. State of the local record: Complete, encrypted, unaffected. The local record is the authoritative copy. Sync failure does not corrupt or alter the local record.
5. What the worker sees: The sync status indicator for this record updates to "Pending." No error dialog is shown. No action is required from the worker. The screening session is complete and the PDF has already been generated — the worker can continue with her visit.
6. When connectivity returns: The sync client detects connectivity (using a passive network state listener, not a polling timer) and automatically retries the sync for all records in "Pending" state. This retry is silent — no notification to the worker unless the worker explicitly views the sync status screen.
7. On successful retry: the record's sync status updates to "Synced."
8. The sync queue persists across app restarts. If the app is closed and reopened while a record is in "Pending" state, the retry fires when the next connectivity event is detected after app reopen.

### Edge Case 4: High Risk Result on Both Conditions

1. Classification completes. Anemia risk = High (a* < 5). Jaundice risk = High (b* ≥ 15).
2. Result screen is displayed. Both results are shown simultaneously. Both use the High Risk color and icon (red, distinct icon — defined by UI/UX designer in the icon set).
3. A prominent banner or highlighted section appears above the risk tiles, separate from the risk labels: "Immediate referral recommended. Take this patient to the PHC today." Text is in the active language. Font size is minimum 14sp. Color is distinct from the standard risk color — a high-urgency treatment that is visually distinct from a standard risk label.
4. Beneath each risk tile, the plain-language recommended action is shown:
   - Anemia: "Refer to PHC for blood test today."
   - Jaundice: "Refer to PHC for clinical assessment today."
5. The mandatory disclaimer is displayed in full below the results and above the PDF generation button.
6. Worker taps "Generate PDF."
7. PDF contents for a dual High Risk result:
   - Patient reference (entered at export time)
   - Date and time of screening
   - Anemia risk level: HIGH RISK
   - Recommended action for anemia: "Refer to PHC for blood test today."
   - Jaundice risk level: HIGH RISK
   - Recommended action for jaundice: "Refer to PHC for clinical assessment today."
   - Prominent referral instruction: "Immediate referral recommended."
   - Full mandatory disclaimer text
   - Quality gate flag if manual override was used: "Note: This result was captured without passing all image quality checks. Reliability may be reduced."
   - App name and version number
   - PDF filename: SCREEN_[YYYYMMDD]_[4-digit random ID].pdf
8. Difference from a Low Risk PDF: A Low Risk PDF does not contain the prominent referral instruction banner. It contains the same structure with Low Risk labels and a recommended action of "Continue routine monitoring. Refer if symptoms appear." The mandatory disclaimer appears on all PDFs regardless of risk level.

### Edge Case 5: White Reference Photo Fails or Is Skipped

If the white reference image fails validation:

1. Worker attempts white reference capture. App assesses the image and finds it does not meet validity criteria (mean pixel intensity < 180 in one or more channels, excessive color bias, or overexposure in > 5% of pixels).
2. App displays specific corrective guidance — not a generic error. Guidance is determined by failure type:
   - **Too dark:** "The white surface is too dark. Use a plain white sheet of paper in better light."
   - **Color bias detected:** "The surface is not white enough. Use a plain white sheet — not cream or yellow paper."
   - **Overexposed:** "Move the phone away from direct light and try again."
3. Worker retries. There is no limit on white reference retries — it is not a blocking flow that locks after 3 attempts in the same way as image quality gating.
4. If the worker retries and fails again: the same guidance appears. The worker can attempt as many times as needed.

If the worker attempts to skip white reference:

- App blocks the screening session from proceeding without a valid white reference. This is a hard gate, not a warning-and-continue.
- **The reason this is a hard block and not a warning:** white-patch gain normalization is applied to the captured image ROIs. Without a valid white reference, the CIELAB values computed from the ROIs are uncorrected for ambient lighting and cannot be compared to the classification thresholds with any reliability. A result generated without white reference normalization would have no defined relationship to the thresholds and could not be interpreted.
- The skip option is not offered in the UI. The capture screen is inaccessible until a valid white reference has been recorded for the current session.
- White reference validity expires at session end. A new session requires a new white reference capture.

---

## 6. FUNCTIONAL REQUIREMENTS

### Requirement Format

```
FR-[AREA].[NUMBER]: [NAME]
WHAT: One declarative sentence describing the requirement.
GIVEN: The precondition that must be true.
WHEN: The action or event that triggers the requirement.
THEN: The specific, measurable outcome.
PRIORITY: MUST HAVE / SHOULD HAVE / NICE TO HAVE
DEPENDS ON: What must exist or be complete first.
RISK: The specific technical failure mode to plan against.
```

---

### Feature Area 1: Consent and Session Initiation

**FR-CS.001: Language Selection on First Launch**
- **WHAT:** The app presents a language selection screen on first launch before any other content is shown.
- **GIVEN:** The app is opened for the first time on a device, or the stored language preference has been cleared.
- **WHEN:** The app completes cold start.
- **THEN:** A language selection screen is displayed with three options — Telugu, Hindi, English — each labeled in its own script. Tapping a language stores the preference locally and advances to the consent screen. The stored preference is loaded automatically on subsequent launches without re-presenting the language selection screen unless the user changes it in settings.
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** App scaffold and navigation structure (FR-CS.001 is the entry point of the entire app).
- **RISK:** String files for Telugu and/or Hindi are incomplete at build time, causing the UI to fall back to English character codes or blank labels. Mitigation: UI/UX designer must sign off on Telugu string file completeness before language selection screen is merged.

**FR-CS.002: Consent Screen Display Before Each Volunteer Study Session**
- **WHAT:** The consent screen is displayed before the first screening capture in every session initiated on a device participating in the volunteer study.
- **GIVEN:** The user has selected a language and the app is in study mode (configurable at build time, not at runtime).
- **WHEN:** The user initiates a new screening session from the home screen.
- **THEN:** The consent screen is displayed in the active language before the camera or any data collection is activated. The consent screen contains: (1) the purpose of the screening — optical triage aid, not diagnosis; (2) what data is collected and stored — anonymized risk classification, no name, no photo; (3) data storage duration — 30 calendar days from capture date; (4) anonymization confirmation — no name or biometric identifier is stored; (5) the right to refuse — the patient may decline and no data will be collected. The consent screen has two controls: "I Agree" and "I Decline."
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** FR-CS.001 (language selection must be complete).
- **RISK:** Consent screen is translated incorrectly and volunteers do not understand what they are consenting to. Mitigation: consent form text must be reviewed by a native Telugu and Hindi speaker before the volunteer study begins. This is an ethics logistics task owned by Project Lead.

**FR-CS.003: Consent Recorded Locally with Timestamp**
- **WHAT:** When a user confirms consent, the consent event is recorded locally in the encrypted database with a timestamp.
- **GIVEN:** The consent screen is displayed.
- **WHEN:** The user taps "I Agree."
- **THEN:** A consent record is written to the local encrypted database containing: session ID, timestamp (ISO 8601 format, device local time), language in which consent was displayed, and consent status (agreed). This record is included in the sync payload. This record is subject to the same 30-day deletion rule as screening records.
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** FR-LS.001 (local storage must be initialized before consent can be written).
- **RISK:** App crashes between consent confirmation and database write, leaving no consent record for a session that proceeds. Mitigation: consent is written to the database as the first action after the user taps "I Agree," before the camera screen is displayed. If the write fails, the session does not proceed.

**FR-CS.004: Clean Exit on Consent Decline**
- **WHAT:** If a user declines consent, the app exits the screening flow cleanly with no data saved.
- **GIVEN:** The consent screen is displayed.
- **WHEN:** The user taps "I Decline."
- **THEN:** The app returns to the home screen. No session record is created. No camera is activated. No data of any kind is written to local storage. The consent decline event itself is not logged — a person who declines consent has not consented to having their decline recorded.
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** FR-CS.002 (consent screen must exist).
- **RISK:** A partial session record or an empty session ID is created before the user reaches the consent screen. Mitigation: no session object is instantiated and no database write is initiated until after consent is confirmed.

**FR-CS.005: Consent Screen Available in Telugu, Hindi, and English**
- **WHAT:** All text on the consent screen — title, body, both control labels — is available in Telugu, Hindi, and English.
- **GIVEN:** A language has been selected (FR-CS.001).
- **WHEN:** The consent screen is rendered.
- **THEN:** Every text element on the consent screen is displayed in the active language. No English text appears on the consent screen when Telugu or Hindi is the active language, except proper nouns (e.g., app name) that are not translated. This applies to both control labels ("I Agree" / "I Decline") as well.
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** FR-CS.001 (language selection), FR-L11.001 (localization string files complete for consent screen content).
- **RISK:** Telugu rendering fails due to font embedding issue in the Flutter text renderer. This is a known risk for Telugu script in some Flutter builds. Mitigation: explicitly test Telugu rendering on the consent screen on Days 1–2 as a Phase 1 go/no-go requirement.

---

### Feature Area 2: White Reference Capture

**FR-WR.001: White Reference Prompt Before Each Session**
- **WHAT:** The app prompts the ASHA worker to capture a white reference image before every screening session.
- **GIVEN:** Consent has been confirmed for the current session.
- **WHEN:** The worker advances from the consent screen to the screening flow.
- **THEN:** A dedicated white reference capture screen is displayed before the camera is opened for patient eye capture. The screen shows an icon-based instruction — photograph a white surface — and a capture button. The worker cannot reach the eye capture screen without completing the white reference step or encountering a hard block (FR-WR.005).
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** FR-CS.002 (consent must be complete before white reference is prompted).
- **RISK:** Worker skips the white reference step by navigating directly to the capture screen via back/forward navigation. Mitigation: the eye capture screen is not accessible from the app's navigation graph until a valid white reference has been recorded for the current session.

**FR-WR.002: White Reference Image Validity Assessment**
- **WHAT:** The app assesses each white reference image against three validity criteria before accepting it.
- **GIVEN:** The worker has captured a white reference image.
- **WHEN:** The white reference image is received from the camera.
- **THEN:** The app evaluates:
  1. **Brightness:** Mean pixel intensity in all three RGB channels must be ≥ 180. Images below this threshold are too dark for valid gain calculation.
  2. **Neutrality:** The standard deviation of mean values across the R, G, and B channels must be ≤ 15. Values outside this range indicate the reference surface has a color cast and will introduce systematic error in the corrected captures.
  3. **Non-overexposure:** No more than 5% of pixels in any channel may be clipped at the maximum value (255). Overexposed references produce gain values of 1/255, which collapse the dynamic range of corrected images.
- All three criteria must pass simultaneously for the white reference to be accepted. If all pass, white-patch gains are calculated (per-channel mean of the reference image) and stored in the current session object in memory.
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** Camera permission granted; white reference capture screen displayed (FR-WR.001).
- **RISK:** Reference surface material (standard A4 paper) has sufficient variation across batches and lighting conditions to produce borderline readings. Mitigation: thresholds are set conservatively; study protocol specifies that reference paper must be matte white A4 or equivalent.

**FR-WR.003: Specific Corrective Guidance on White Reference Failure**
- **WHAT:** When a white reference image fails one or more validity criteria, the app displays guidance specific to the failure mode — not a generic error.
- **GIVEN:** A white reference image has been captured and assessed (FR-WR.002).
- **WHEN:** One or more validity criteria fail.
- **THEN:** The app displays guidance determined by the failure type:
  - **Brightness failure** (mean intensity < 180): "The image is too dark. Move to a brighter area or use a brighter light source, then try again."
  - **Neutrality failure** (channel standard deviation > 15): "Use a plain white surface — not cream, yellow, or colored paper — and try again."
  - **Overexposure failure** (> 5% pixels clipped): "The image is overexposed. Move away from direct light and try again."
- If multiple criteria fail simultaneously, all applicable messages are shown — one per failure. The worker taps "Try Again" to retry capture. There is no limit on retry attempts for white reference.
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** FR-WR.002.
- **RISK:** All three failure modes occur but only one message is shown, leaving the worker unable to resolve the compound failure. Mitigation: failure detection logic returns a bitmask or list of all failing criteria, not just the first one encountered.

**FR-WR.004: White-Patch Gains Applied to All Session Captures**
- **WHAT:** White-patch gain values calculated from the accepted white reference image are applied to the ROI pixel data of every capture in that session before CIELAB conversion.
- **GIVEN:** A valid white reference has been accepted for the current session and gains have been calculated and stored in the session object.
- **WHEN:** An ROI is extracted from a captured patient eye image.
- **THEN:** Each pixel value in the ROI is divided by the per-channel white-patch gain (R_pixel / R_gain, G_pixel / G_gain, B_pixel / B_gain, clamped to [0, 1]) before conversion to CIELAB. This normalization step is non-optional and is applied to every ROI in the session.
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** FR-WR.002 (gains must have been calculated and stored); FR-CA.003 (ROI extraction must produce RGB pixel data).
- **RISK:** Gain values are stored in a session object that is garbage-collected between white reference capture and eye capture — possible in low-memory conditions on the reference device. Mitigation: gains are stored in a persistent session state object managed outside the camera pipeline widget, not as local variables.

**FR-WR.005: White Reference is a Hard Gate — Skip is Not Offered**
- **WHAT:** The eye capture screen is not accessible until a valid white reference has been accepted for the current session.
- **GIVEN:** The worker is in the screening flow for the current session.
- **WHEN:** The worker attempts to navigate to the eye capture screen without a valid white reference.
- **THEN:** Navigation to the eye capture screen is blocked. The white reference screen is the only screen accessible. No option to skip is shown in the UI. The reason this is a hard block: CIELAB values computed without ambient light normalization have no defined relationship to the classification thresholds and would produce results that cannot be interpreted against those thresholds.
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** FR-WR.002.
- **RISK:** Navigation routing bypasses the white reference guard — e.g., deep link or Android back stack manipulation. Mitigation: white reference validity is checked in the Flutter route guard (onGenerateRoute or Navigator 2.0 equivalent), not only in the UI button state.

**FR-WR.006: White Reference Expires at Session End**
- **WHAT:** White-patch gain values stored in the session object are discarded at the end of each screening session and do not carry over to subsequent sessions.
- **GIVEN:** A screening session has been completed or abandoned.
- **WHEN:** The worker initiates a new session.
- **THEN:** The session object from the previous session — including its stored gain values — is discarded. The new session requires a new white reference capture. Gains from a previous session are not applied to the new session under any circumstances.
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** Session lifecycle management in the app state layer.
- **RISK:** Session state is retained across app restarts (e.g., app is backgrounded and resumed), causing stale gains to be used in a new lighting environment. Mitigation: session object is cleared on app resume if the session was not in an active capture state.

---

### Feature Area 3: Capture and AR Guidance

**FR-CA.001: Face Mesh Tracking Using google_mlkit_face_mesh_detection**
- **WHAT:** The app uses the google_mlkit_face_mesh_detection package to track face mesh landmarks in real time on the camera preview.
- **GIVEN:** The camera preview is active and the worker has opened the eye capture screen.
- **WHEN:** Each camera frame is processed.
- **THEN:** Face mesh landmarks are detected and the following eye landmark indices are used for ROI definition:
  - Left eye: indices 33, 133, 159, 145
  - Right eye: indices 362, 263, 386, 374
- These indices define the bounding region for conjunctiva and sclera ROI extraction. If no face is detected in a frame, the AR overlay shows a "Position the eye in the frame" prompt and the capture button remains disabled.
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** google_mlkit_face_mesh_detection package confirmed compatible with target Flutter version (version pinned — see Section 13).
- **RISK:** The ML Kit face mesh model fails to detect a face in non-frontal poses or with high skin tone variance. Mitigation: the AR overlay guidance directs the worker to position the device perpendicular to the patient's face; testing must include Fitzpatrick scale IV–VI volunteers.

**FR-CA.002: AR Overlay Positioning Guide**
- **WHAT:** The camera preview displays an AR overlay that guides the worker to position the device relative to the patient's eye.
- **GIVEN:** Face mesh tracking is active (FR-CA.001).
- **WHEN:** The camera preview is rendered each frame.
- **THEN:** The overlay shows: (1) a translucent ellipse indicating the target position and size of the eye in the frame; (2) directional arrows or a proximity indicator guiding the worker to move closer, farther, left, or right as needed; (3) color or icon-based status indicators for each quality gate (blur, exposure, eye openness) updating in real time. The overlay does not obstruct the central camera preview area. The overlay is visually distinct from the patient's eye — use contrasting color (white or yellow outline on dark background).
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** FR-CA.001 (face mesh tracking), quality gate logic (FR-QG.001–FR-QG.004).
- **RISK:** Overlay rendering adds sufficient GPU load to drop frame rate below 20 FPS on the reference device. Mitigation: overlay is drawn using Canvas API on a transparent overlay widget, not as a separate camera pass; complexity is reduced to the minimum elements that communicate positioning guidance.

**FR-CA.003: ROI Extraction for Conjunctiva and Sclera**
- **WHAT:** From a single captured image, the app extracts two separate ROIs — one for the conjunctival region (anemia) and one for the scleral region (jaundice).
- **GIVEN:** A capture has been triggered (capture button was active and the worker tapped it).
- **WHEN:** The captured image is processed.
- **THEN:** Using the face mesh landmarks confirmed at the moment of capture:
  - **Conjunctival ROI:** The lower palpebral conjunctiva region, bounded by landmarks 33, 133, 145, and 159 for the left eye or 362, 263, 374, and 386 for the right eye, cropped with a 10% inward margin to avoid eyelid skin pixels.
  - **Scleral ROI:** The visible white sclera region within the same landmark bounding box, excluding the iris region (identified as the central circle with radius proportional to the inter-landmark distance). Both ROIs are extracted from the same captured image in the same processing pass.
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** FR-CA.001 (landmark positions must be available at capture time).
- **RISK:** At the moment of capture, a blink or micro-movement causes the face mesh position to differ from the pre-capture position, resulting in an ROI that includes eyelid skin. Mitigation: quality gate FR-QG.003 (eye openness EAR > 0.2) must pass at the frame immediately preceding capture; capture is triggered from that frame's landmark positions.

**FR-CA.004: AR Guidance at Minimum 20 FPS on Reference Device**
- **WHAT:** The camera preview with face mesh tracking and AR overlay renders at a minimum of 20 FPS on the reference device.
- **GIVEN:** The app is running on Snapdragon 665, 4GB RAM, Android 10 or later.
- **WHEN:** The eye capture screen is active and face mesh tracking is running.
- **THEN:** Frame rate is measured at the camera preview widget level. The 20 FPS minimum is sustained for a 30-second continuous session — not just at peak performance. Measurement is performed during Phase 2 testing on the reference device.
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** FR-CA.001, FR-CA.002; device hardware.
- **RISK:** Face mesh model inference time exceeds the frame budget for 20 FPS (50ms per frame). Mitigation: ML Kit face mesh is optimized for mobile and uses hardware acceleration; if frame budget is exceeded, the ML/CV Engineer reduces overlay complexity before other mitigations.

**FR-CA.005: FPS Degradation Behavior on Lower-Spec Devices**
- **WHAT:** If the AR frame rate drops below 15 FPS, the app detects this and reduces overlay complexity to recover frame rate.
- **GIVEN:** The app is running on a device below the reference spec.
- **WHEN:** The measured frame rate on the capture screen drops below 15 FPS for more than 3 consecutive seconds.
- **THEN:** The app automatically reduces the AR overlay to a static positioning guide — a fixed ellipse with no directional animation — and displays an icon-based indicator that the dynamic overlay has been simplified. If frame rate does not recover to ≥ 15 FPS within 5 seconds of reduction, the dynamic overlay is disabled entirely and replaced with a static image guide ("Position the eye inside the circle"). Quality gating continues to function. Capture remains possible. The worker is not shown an error; she is shown a simplified guide.
- **PRIORITY:** SHOULD HAVE
- **DEPENDS ON:** FR-CA.002, FR-CA.004; frame rate measurement utility.
- **RISK:** Frame rate measurement utility itself consumes CPU and worsens the degradation it is trying to detect. Mitigation: frame rate is measured by counting rendered frames against a timer at the widget level — no additional native call.

---

### Feature Area 4: Image Quality Gating

**FR-QG.001: Blur Gate — Laplacian Variance**
- **WHAT:** Each camera frame is evaluated for blur using Laplacian variance; frames with variance ≤ 100 are classified as too blurry for reliable capture.
- **GIVEN:** The eye capture screen is active and face mesh tracking is running.
- **WHEN:** Each camera frame is processed by the quality gate pipeline.
- **THEN:** The Laplacian variance of the eye ROI region in the current frame is computed. If the variance is > 100, the blur gate passes. If ≤ 100, the blur gate fails. The blur gate status is communicated to the worker via the AR overlay indicator. The capture button state is determined by the conjunction of all gate states (FR-QG.004).
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** FR-CA.001 (ROI must be definable from landmarks).
- **RISK:** Laplacian computation on every frame at 20 FPS on the reference device consumes sufficient CPU to degrade frame rate. Mitigation: Laplacian is computed on a downsampled version of the ROI (maximum 100×100 pixels) — the variance magnitude is scale-dependent but the threshold is set against the downsampled computation and will be validated on the reference device during Phase 2.

**FR-QG.002: Exposure Gate — Mean Pixel Intensity**
- **WHAT:** Each frame is evaluated for exposure; frames outside the mean pixel intensity range of 40–200 are classified as incorrectly exposed.
- **GIVEN:** The eye capture screen is active.
- **WHEN:** Each camera frame is processed by the quality gate pipeline.
- **THEN:** The mean pixel intensity of the eye ROI region (averaged across R, G, B channels) is computed. If the mean is between 40 and 200 inclusive, the exposure gate passes. If < 40, the frame is underexposed. If > 200, the frame is overexposed. The exposure gate status is shown in the AR overlay.
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** FR-CA.001.
- **RISK:** Auto-exposure on the Android camera API causes frame-to-frame intensity fluctuation that makes the gate flicker. Mitigation: exposure gate uses a rolling mean over 5 consecutive frames before changing gate state — prevents flicker caused by single-frame AE adjustments.

**FR-QG.003: Eye Openness Gate — Eye Aspect Ratio**
- **WHAT:** Each frame is evaluated for eye openness using Eye Aspect Ratio (EAR); frames with EAR ≤ 0.2 are classified as insufficiently open for ROI extraction.
- **GIVEN:** Face mesh landmarks are detected in the current frame.
- **WHEN:** Each camera frame is processed by the quality gate pipeline.
- **THEN:** EAR is computed from the face mesh landmarks for the eye being screened. EAR = (vertical distance between landmarks 159 and 145) / (horizontal distance between landmarks 33 and 133) for the left eye; equivalent for the right eye using indices 386, 374, 362, 263. If EAR > 0.2, the gate passes. If ≤ 0.2, the gate fails. The gate status is shown in the AR overlay.
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** FR-CA.001.
- **RISK:** ML Kit face mesh returns inaccurate landmark positions for small or partially occluded eyes (common in neonatal subjects or elderly patients), producing EAR values that do not reflect actual eye openness. Mitigation: EAR computation is validated against a set of reference images during Phase 2; if systematic error is found for specific demographics, the threshold is adjusted before the volunteer study.

**FR-QG.004: All Gates Must Pass Simultaneously for Capture**
- **WHAT:** The capture button is enabled only when all three quality gates — blur, exposure, and eye openness — pass simultaneously in the current frame.
- **GIVEN:** The eye capture screen is active.
- **WHEN:** The quality gate pipeline evaluates a frame.
- **THEN:** The capture button is enabled (tappable) only if FR-QG.001 AND FR-QG.002 AND FR-QG.003 all pass for the same frame evaluation cycle. If any gate fails, the capture button is disabled. The state changes in real time as the worker repositions. The worker cannot trigger a capture while any gate is failing — there is no way to tap a disabled button.
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** FR-QG.001, FR-QG.002, FR-QG.003.
- **RISK:** Race condition between gate state evaluation and button state rendering causes the button to enable briefly on a frame that does not meet all criteria. Mitigation: capture is triggered from a frame that has been explicitly validated — the captured image is the frame that triggered the enable state, not the next frame after button tap.

**FR-QG.005: Per-Gate Specific Guidance on Failure**
- **WHAT:** When one or more quality gates fail, the app shows specific guidance for each failing gate — not a generic error message.
- **GIVEN:** The eye capture screen is active and one or more gates are failing.
- **WHEN:** A gate transitions to failing state.
- **THEN:** The following guidance text appears for each failing gate:
  - **Blur gate failing:** "Hold the phone very still. Rest your elbow if possible."
  - **Exposure gate failing — underexposed:** "Move to a brighter spot or face a window."
  - **Exposure gate failing — overexposed:** "Step back from direct sunlight."
  - **Eye openness gate failing:** "Ask the patient to open their eye wider and look forward."
- If multiple gates fail simultaneously, all applicable messages are shown. Messages are displayed in the active language. Messages use plain language with no medical terminology.
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** FR-QG.001–FR-QG.004; localization strings for all three failure types in Telugu, Hindi, and English (FR-L11.001).
- **RISK:** Multiple simultaneous gate failures produce a cluttered UI with overlapping guidance messages. Mitigation: UI/UX designer must wireframe the multi-failure state explicitly; guidance messages are displayed in a fixed panel below the camera preview, not overlaid on the AR canvas.

**FR-QG.006: Manual Override After Three Consecutive Failures**
- **WHAT:** After three consecutive failed capture attempts, the app offers the worker a manual override option, with a warning displayed before the override capture proceeds.
- **GIVEN:** The worker has attempted capture three times and all three attempts have been rejected by the quality gate.
- **WHEN:** The worker triggers the third failed capture attempt.
- **THEN:** A modal dialog is displayed with two options — "Try Again" and "Continue Without Quality Check." If the worker selects "Continue Without Quality Check": (1) a warning screen is shown reading "This image has not passed quality checks. The result may be less reliable. This will be noted in the report." in the active language; (2) the worker must tap a confirmation control to proceed; (3) capture proceeds with the override; (4) the captured result is flagged in local storage with `quality_override: true`; (5) the PDF from this session includes the quality override notice.
- **PRIORITY:** SHOULD HAVE (see Section 11 cut priority — can be cut for demo if timeline is at risk)
- **DEPENDS ON:** FR-QG.001–FR-QG.005.
- **RISK:** Workers use the manual override routinely to skip quality gating, degrading the reliability of the volunteer study data. Mitigation: the override warning must be sufficiently prominent that it is not a default path; study protocol instructs workers to retry before overriding; override flag in the data allows these records to be analyzed separately.

**FR-QG.007: Quality Gate Result Logged with Each Record**
- **WHAT:** The quality gate outcome — passed normally, or override used — is stored with every screening record in local storage and included in the sync payload.
- **GIVEN:** A screening result has been generated (with or without override).
- **WHEN:** The result is written to local storage.
- **THEN:** The local record and the sync payload both contain the field `quality_override: boolean` — false if all gates passed normally, true if the manual override was used. This field is used in data analysis to identify records with potentially reduced image quality.
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** FR-LS.001 (local storage schema); FR-QG.006 (override logic).
- **RISK:** Override flag is not written to the database if the app crashes between capture and write. Mitigation: flag is written as part of the atomic result write (see FR-LS.001 — result is written atomically on completion).

---

### Feature Area 5: AI Analysis and Classification

**FR-AI.001: CIELAB Conversion from ROI Pixel Data**
- **WHAT:** The app converts the RGB pixel data of both extracted ROIs to the CIELAB color space as the first step of analysis.
- **GIVEN:** ROIs for conjunctiva and sclera have been extracted from the captured image and white-patch gain normalization has been applied (FR-WR.004).
- **WHEN:** Analysis begins after capture is confirmed.
- **THEN:** The mean RGB values of the conjunctival ROI and the scleral ROI are each converted to CIELAB using the standard ICC conversion pipeline: sRGB → linear RGB → CIE XYZ (D65 illuminant, 2° observer) → CIELAB. The resulting a* value from the conjunctival ROI is used for anemia classification. The resulting b* value from the scleral ROI is used for jaundice classification. The L* value is logged internally for debugging but is not used in classification or displayed to the user.
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** FR-CA.003 (ROI extraction); FR-WR.004 (gain normalization).
- **RISK:** sRGB gamma correction assumption is incorrect for the device's camera pipeline, producing systematically offset CIELAB values. Mitigation: the ML/CV Engineer validates the conversion against reference color patches photographed on the reference device during Phase 2 calibration testing; deviation from expected CIELAB values for reference patches must be < 2 ΔE before the volunteer study begins.

**FR-AI.002: Anemia Classification from a* Value**
- **WHAT:** The anemia risk classification is determined by comparing the a* value from the conjunctival ROI to defined thresholds.
- **GIVEN:** CIELAB conversion has been performed for the conjunctival ROI.
- **WHEN:** The a* value is computed.
- **THEN:** The classification is determined as follows:
  - **High Risk:** a* < 5
  - **Moderate Risk:** 5 ≤ a* < 10
  - **Low Risk:** a* ≥ 10
- The classification label (High Risk / Moderate Risk / Low Risk) is the only output presented to the worker. The numerical a* value is not displayed on any user-facing screen. The a* value is stored internally in the local record for analysis purposes but is not shown to the worker or included in the PDF.
- **Source of thresholds:** Tamir et al. (2017) [Reference 1]. These thresholds are literature-derived and have not been independently validated in this study. This is a named limitation — see Section 9, Limitation 1.
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** FR-AI.001.
- **RISK:** CIELAB a* values computed from smartphone camera data are systematically offset from values computed from spectrophotometer data, rendering the literature thresholds miscalibrated for this hardware. Mitigation: validation against reference images during Phase 2; if a systematic offset is detected, a correction factor is documented and applied, and the offset is reported as a limitation in the study report.

**FR-AI.003: Jaundice Classification from b* Value**
- **WHAT:** The jaundice risk classification is determined by comparing the b* value from the scleral ROI to defined thresholds.
- **GIVEN:** CIELAB conversion has been performed for the scleral ROI.
- **WHEN:** The b* value is computed.
- **THEN:** The classification is determined as follows:
  - **High Risk:** b* ≥ 15
  - **Moderate Risk:** 10 ≤ b* < 15
  - **Low Risk:** b* < 10
- The classification label is the only output presented to the worker. The numerical b* value is not displayed on any user-facing screen. The b* value is stored internally.
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** FR-AI.001.
- **RISK:** Scleral b* values are confounded by skin tone, particularly for Fitzpatrick scale V–VI subjects, where the scleral-to-skin boundary used by the landmark-based segmentation may introduce non-scleral pixels into the ROI. Mitigation: Fitzpatrick scale is logged as a confounder; analysis reports accuracy stratified by skin tone category.

**FR-AI.004: Both Classifications Run on the Same Session**
- **WHAT:** Every screening session produces both an anemia classification and a jaundice classification from the same captured image.
- **GIVEN:** A valid capture has been made and ROIs extracted.
- **WHEN:** Analysis is performed.
- **THEN:** Both FR-AI.002 and FR-AI.003 are executed on the same captured image in the same processing pass. There is no session type that produces only one classification. If either classification cannot be computed (e.g., ROI extraction fails for one region), the session is treated as failed and the worker is prompted to retry — not to accept a partial result.
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** FR-CA.003, FR-AI.001, FR-AI.002, FR-AI.003.
- **RISK:** Scleral ROI extraction fails for a subject with limited scleral visibility due to deep-set eyes or narrow palpebral fissure, making it impossible to produce a jaundice classification. Mitigation: if scleral ROI is below a minimum pixel count (< 200 pixels), the worker is informed that the jaundice screening could not be completed for this capture and is offered a retry — this is treated as a quality failure, not as a "Low Risk" default.

**FR-AI.005: Classification Completes in Under 3 Seconds**
- **WHAT:** The time from capture confirmation to result display is under 3 seconds on the reference device.
- **GIVEN:** The app is running on the reference device (Snapdragon 665, 4GB RAM).
- **WHEN:** The worker taps the capture button and the capture is confirmed.
- **THEN:** The result screen is displayed within 3 seconds. This includes ROI extraction, gain normalization, CIELAB conversion, threshold comparison, and result screen rendering. There is no server call involved — all computation is local. A loading indicator is shown during computation if the UI thread would otherwise appear frozen.
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** FR-CA.003, FR-AI.001–FR-AI.004.
- **RISK:** CIELAB conversion is implemented naively using a pixel-by-pixel loop in Dart, consuming 2+ seconds on the reference device. Mitigation: conversion is implemented as a vectorized operation on the mean ROI pixel values (not per-pixel on the full image), which reduces computation to microseconds.

**FR-AI.006: No Raw CIELAB Values Shown to the Worker**
- **WHAT:** CIELAB a*, b*, and L* values are never displayed on any screen visible to the ASHA worker or the patient.
- **GIVEN:** Classification has been performed.
- **WHEN:** Any result is displayed, any PDF is generated, or any screen in the screening flow is rendered.
- **THEN:** The worker sees only the risk classification label (High Risk / Moderate Risk / Low Risk) and the recommended action. CIELAB values are stored in the local database for analysis purposes and are accessible via the backend to the research team — they are not surfaced in the UI under any condition.
- **PRIORITY:** MUST HAVE (this is a regulatory and usability requirement simultaneously)
- **DEPENDS ON:** FR-RD.001 (result display screen design).
- **RISK:** A debug mode or developer option exposes CIELAB values on a production build used in the volunteer study. Mitigation: raw value display is gated behind a build flag (`--dart-define=DEBUG_MODE=true`) that is explicitly not set in the study APK build.

---

### Feature Area 6: Results Display

**FR-RD.001: Both Risk Levels on One Screen**
- **WHAT:** The result screen displays both the anemia risk classification and the jaundice risk classification simultaneously on a single screen, without requiring the worker to scroll or navigate between tabs.
- **GIVEN:** Both classifications have been computed.
- **WHEN:** The result screen is rendered.
- **THEN:** The anemia result and the jaundice result are displayed as two distinct tiles or panels on the same screen. Both are visible without scrolling on a 5-inch screen at standard font size. The mandatory disclaimer is also visible without scrolling (see FR-RD.005 for disclaimer positioning rule).
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** FR-AI.002, FR-AI.003; UI layout validated on a 5-inch screen resolution by the UI/UX designer.
- **RISK:** The mandatory disclaimer text, rendered at 12sp minimum, consumes sufficient vertical space that one or both result tiles are pushed below the scroll fold on a 5-inch screen. Mitigation: UI/UX designer must validate the result screen layout on a 5-inch, 720p screen mockup before implementation begins. If disclaimer + two result tiles cannot fit, the designer proposes a layout adjustment — the disclaimer cannot be reduced.

**FR-RD.002: Risk Label Uses Color and Icon, Not Text Alone**
- **WHAT:** Each risk classification is represented by a color-coded icon as the primary visual element, with a text label as a secondary element.
- **GIVEN:** The result screen is rendered.
- **WHEN:** A risk classification is displayed.
- **THEN:** Each risk level is represented by: (1) a color — red for High Risk, amber/orange for Moderate Risk, green for Low Risk; (2) an icon that is distinct for each risk level and does not rely on color alone to convey meaning (accessibility requirement — colorblind workers must be able to distinguish risk levels from icon shape alone); (3) a text label in the active language. The icon is the largest visual element. The text label is below or beside the icon.
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** Icon set designed and approved by UI/UX designer; color palette defined and validated for colorblindness.
- **RISK:** Icon set is not designed before Flutter Developer 1 implements the result screen, requiring a rework cycle. Mitigation: UI/UX designer completes result screen wireframes and icon definitions by Day 4 (Phase 1 deliverable).

**FR-RD.003: Recommended Next Action in Plain Language**
- **WHAT:** Each risk classification is accompanied by a recommended next action in plain language in the active language.
- **GIVEN:** The result screen is rendered.
- **WHEN:** A risk classification is displayed.
- **THEN:** Below or adjacent to each risk tile, the recommended next action is displayed:
  - **Anemia High Risk:** "Refer to PHC for blood test today."
  - **Anemia Moderate Risk:** "Monitor closely. Refer to PHC within 3 days or if symptoms worsen."
  - **Anemia Low Risk:** "Continue routine monitoring."
  - **Jaundice High Risk:** "Refer to PHC for clinical assessment today."
  - **Jaundice Moderate Risk:** "Monitor closely. Refer to PHC within 24 hours or if yellowing increases."
  - **Jaundice Low Risk:** "Continue routine monitoring."
- All text is in the active language. No medical terminology appears without a plain language equivalent on the same screen.
- **Note:** These recommended actions are operational guidance for the ASHA worker. They are not clinical prescriptions. They must be reviewed by the faculty supervisor with a medical background before the volunteer study begins. This is a project lead responsibility.
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** FR-RD.001; localization strings for all six action texts in Telugu, Hindi, English.
- **RISK:** The recommended actions for moderate risk conditions are clinically ambiguous. Mitigation: action text must be reviewed and approved by a clinician or faculty supervisor before the volunteer study; the approved text is what ships.

**FR-RD.004: High Risk Referral Instruction**
- **WHAT:** When either or both conditions return a High Risk classification, a prominent referral instruction appears on the result screen as an action directive, distinct from the risk label itself.
- **GIVEN:** The result screen is rendered and at least one classification is High Risk.
- **WHEN:** The result screen is displayed.
- **THEN:** A distinct banner or highlighted panel appears above the result tiles reading "Immediate referral recommended. Accompany the patient to the PHC or arrange transport today." in the active language. This element is visually distinct from the risk tiles — larger font, different background color, positioned at the top of the result content area so it is the first element the worker sees after the screen header.
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** FR-RD.001, FR-RD.002.
- **RISK:** Worker sees the High Risk icon but misses the referral instruction if the banner blends visually with the risk tile color. Mitigation: referral banner uses a background color not used elsewhere in the app — to be specified by UI/UX designer.

**FR-RD.005: Mandatory Disclaimer on Every Result Screen**
- **WHAT:** The full mandatory disclaimer text is displayed on every instance of the result screen, in the active language, in a minimum 12sp font, above the scroll fold.
- **GIVEN:** The result screen is being rendered.
- **WHEN:** Any result screen is displayed — regardless of risk level, language, or session type.
- **THEN:** The following text is displayed in full, verbatim, in the active language:

> "This screening result is not a medical diagnosis. It is a triage aid for trained health workers only. All results require confirmation by a qualified medical professional. Do not make treatment decisions based on this result alone."

- **Requirements for display:**
  - Minimum font size: 12sp
  - Must be visible without scrolling on a 5-inch screen (720p minimum resolution)
  - Must not be rendered behind a toggle, collapsed accordion, or "read more" interaction
  - Must not be in a color that is lower contrast than 4.5:1 against the background
  - Must appear in the same language as the rest of the result screen
  - This requirement applies to every render of the result screen — including after a PDF has been generated and the worker returns to the result screen
  - Compliance with this requirement is a test case in the automated test suite, not only a visual design review.
- **PRIORITY:** MUST HAVE — this is a safety requirement
- **DEPENDS ON:** Localization strings for the disclaimer in Telugu and Hindi (FR-L11.001 — these strings are the highest priority localization strings in the project).
- **RISK:** A localization update changes the disclaimer text in Telugu or Hindi to a shortened version, violating the verbatim requirement. Mitigation: the disclaimer text strings in all three languages are locked — they cannot be modified by the normal localization string update process without a documented change approved by the Project Lead. A comment in the string file marks them as locked.

**FR-RD.006: Result Screen Fully Readable on 5-Inch Screen Without Scrolling**
- **WHAT:** The full content of the result screen — both classification tiles, both recommended actions, the referral instruction if High Risk, and the full disclaimer — is visible on a 5-inch screen at 720p without scrolling.
- **GIVEN:** The result screen is rendered.
- **WHEN:** Any result screen is displayed on a device with a 5-inch, 720×1280 pixel display.
- **THEN:** All required elements are visible in the initial viewport. No required element is below the scroll fold. This is validated during UI testing on a physical or emulated 5-inch device before the volunteer study begins.
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** FR-RD.001–FR-RD.005; UI layout design validated by UI/UX designer on a 5-inch emulated screen.
- **RISK:** The disclaimer text in Telugu is longer than the English equivalent, causing the layout to overflow on smaller screens. Mitigation: UI/UX designer must validate the layout with the Telugu disclaimer string (not placeholder lorem ipsum) before implementation is finalized.

---

### Feature Area 7: Local Storage and Encryption

**FR-LS.001: Every Completed Screening Saved Atomically to sqflite Before Sync**
- **WHAT:** Every completed screening result is written to the local sqflite database as an atomic operation upon session completion, before any sync is attempted.
- **GIVEN:** Both classifications have been computed and the result screen has been displayed.
- **WHEN:** The session is marked complete (result screen rendered, worker has not navigated away in an error state).
- **THEN:** A single atomic database write creates a record with all required fields (see FR-LS.003). If the write fails, the worker is informed and the session is held in a retry state — not silently dropped. Sync is not attempted until the local write is confirmed successful.
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** sqflite database initialized and encrypted at app start.
- **RISK:** Atomic write is implemented as multiple sequential writes, making partial records possible on crash between writes. Mitigation: the entire session record is a single sqflite transaction; either all fields are written or none are.

**FR-LS.002: AES-256 Encryption for Local Database**
- **WHAT:** The sqflite database is encrypted using AES-256 at rest.
- **GIVEN:** The app is installed on the device.
- **WHEN:** The database is initialized at first app launch.
- **THEN:** The database is created using the sqflite_sqlcipher or equivalent Flutter package that provides AES-256 encryption. The encryption key is generated at first launch and stored in Android Keystore — not in shared preferences or hardcoded in the app. All subsequent database operations read and write through the encrypted interface. A developer with access to the APK and the device filesystem cannot read the database contents without the key.
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** sqflite_sqlcipher or equivalent package compatibility confirmed with target Flutter version before Day 4.
- **RISK:** The AES-256 sqflite package has not been tested for compatibility with Android 8.0 on the specific device models used in the study. Mitigation: encryption library compatibility is tested on Android 8.0 emulator and on the reference device as a Phase 1 task.

**FR-LS.003: What Is Stored in Each Record**
- **WHAT:** Each screening record in the local database contains exactly the following fields and no others.
- **GIVEN:** A screening session has been completed.
- **WHEN:** The session record is written (FR-LS.001).
- **THEN:** The stored record contains:
  - `screening_id` — UUID generated at session start; not derived from any patient identifier
  - `captured_at` — ISO 8601 timestamp, device local time
  - `anemia_risk` — enum: HIGH / MODERATE / LOW
  - `jaundice_risk` — enum: HIGH / MODERATE / LOW
  - `anemia_a_star` — float, stored for analysis; not displayed in UI
  - `jaundice_b_star` — float, stored for analysis; not displayed in UI
  - `quality_override` — boolean
  - `quality_gate_result` — JSON object logging which gates passed and which failed
  - `device_model` — string, captured programmatically
  - `fitzpatrick_scale` — integer 1–6, recorded by worker or study administrator
  - `fitzpatrick_assessment_method` — enum: SELF_REPORTED / WORKER_ASSESSED
  - `ambient_lighting` — enum: INDOOR_NATURAL / INDOOR_ARTIFICIAL / OUTDOOR / MIXED
  - `sync_status` — enum: PENDING / SYNCED / FAILED
  - `consent_recorded_at` — ISO 8601 timestamp of the consent event for this session
  - `deleted_at` — null until deletion trigger; set to 30 days after captured_at — used by the deletion scheduler
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** FR-LS.001, FR-LS.002.
- **RISK:** A developer adds a patient name or identifier field to the schema during implementation, creating a data handling violation. Mitigation: the schema is reviewed against this list before any data is collected; the PR that creates the schema requires sign-off from the Project Lead.

**FR-LS.004: What Is Never Stored**
- **WHAT:** The following data is explicitly prohibited from being written to the local database or to any file created by the app, except as specified in FR-PDF.003.
- **GIVEN:** Any point in the app's operation.
- **WHEN:** Any data write operation occurs.
- **THEN:** The following must not be present in local storage, sync payloads, or any app-generated file except the PDF:
  - Patient name
  - Patient photograph (captured images are processed in memory and discarded; they are not saved to local storage or the camera roll)
  - Any biometric identifier (fingerprint, facial geometry, iris pattern)
  - GPS coordinates or location data
  - ASHA worker personal details (name, ID, phone number)
  - Any field that could be used to re-identify an individual patient
- Captured images (including the white reference image and the eye capture) exist only in memory during processing and are not persisted to any storage medium after ROI extraction and CIELAB computation are complete.
- **PRIORITY:** MUST HAVE — this is a privacy requirement, not a feature
- **DEPENDS ON:** FR-LS.003 (schema is defined to contain only permitted fields).
- **RISK:** The Android camera API saves a copy of the captured image to the device camera roll by default, depending on how the camera is invoked. Mitigation: the camera is invoked using the Flutter camera plugin in a mode that writes to a temporary in-memory buffer, not to the camera roll; this behavior must be verified on the reference device during Phase 2 testing.

**FR-LS.005: Automatic 30-Day Deletion**
- **WHAT:** Each screening record is automatically and permanently deleted from local storage exactly 30 calendar days from the date of its individual capture, without any action required from the ASHA worker.
- **GIVEN:** A record exists in the local database.
- **WHEN:** The app is opened and the deletion scheduler runs (scheduler runs at app launch and once every 24 hours while the app is open).
- **THEN:** Any record where `captured_at` is more than 30 calendar days before the current date is deleted using a sqflite DELETE operation with no soft-delete flag. Deletion is permanent and irreversible. The deletion event is not logged (logging the deletion would create a record of a deleted record, which partially defeats the privacy purpose). Deleted records are removed from the sync queue.
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** FR-LS.003 (captured_at field must be stored accurately).
- **RISK:** The device clock is set incorrectly, causing records to be deleted earlier or later than 30 days. Mitigation: the deletion scheduler uses the device system clock; the consent form communicates that data is deleted "approximately 30 days from capture" to account for this variability; no clinical decision depends on the exact moment of deletion.

**FR-LS.006: App Uninstall Behavior**
- **WHAT:** If the app is uninstalled before the 30-day deletion date, local data is deleted with the app.
- **GIVEN:** The app is installed and local records exist.
- **WHEN:** The user uninstalls the app via Android system settings.
- **THEN:** sqflite database files are stored in the app's internal storage directory, which Android deletes automatically on uninstall. No additional deletion code is required. Any synced records on the backend are not affected by app uninstall — they follow the backend deletion schedule independently. This distinction must appear in the volunteer consent form.
- **PRIORITY:** MUST HAVE (by Android platform behavior — the app must not save database files outside of internal storage)
- **DEPENDS ON:** Database file location in the Flutter sqflite initialization.
- **RISK:** The database is initialized with a path in external storage (e.g., Documents folder), which Android does not delete on uninstall. Mitigation: database path is explicitly set to the application documents directory (returned by `getDatabasesPath()` in sqflite), which is internal storage and deleted on uninstall.

---

### Feature Area 8: PDF Report Generation

**Privacy Resolution Note (Authoritative):**
The local database stores no patient name or identifier (FR-LS.004). The PDF must be useful as a referral document and must identify the patient. Resolution: the ASHA worker enters a patient reference (name or household ID) at the time of PDF generation only. This reference is written to the PDF and then immediately discarded from memory. It is never written to the local database. It is never included in any sync payload. This is the only moment in the app's operation where a patient-identifying string exists in the system. The implementation must enforce this exactly.

**FR-PDF.001: Patient Reference Entry at Export Time Only**
- **WHAT:** The PDF generation screen prompts the ASHA worker to enter a patient reference immediately before PDF generation; this reference is the only point of entry for patient-identifying information in the entire app.
- **GIVEN:** The worker has completed a screening session and tapped "Generate PDF."
- **WHEN:** The PDF generation screen is displayed.
- **THEN:** A text input field is displayed with the label "Patient name or household ID" in the active language. Entry is optional — the worker may leave it blank if the patient prefers not to have their name on the document. If left blank, the PDF header shows "Patient: [Not provided]." After the worker taps "Generate," the entered text is used in PDF generation and then discarded. No copy of the entered text is retained in any variable, database, cache, or log after the PDF file is written.
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** PDF generation library (FR-PDF.002).
- **RISK:** The text field value is retained in a state variable that persists after PDF generation, causing it to appear pre-filled in the next session's PDF generation screen. Mitigation: the patient reference field is part of a one-time form widget that is disposed after PDF generation completes; the value is not stored in the app state layer.

**FR-PDF.002: PDF Generated Locally in Under 5 Seconds**
- **WHAT:** The PDF file is generated entirely on-device with no network request, and the generated file is available for sharing within 5 seconds of the worker tapping "Generate."
- **GIVEN:** The patient reference has been entered (or left blank) and the worker has tapped "Generate."
- **WHEN:** PDF generation begins.
- **THEN:** The PDF is generated in under 5 seconds on the reference device. Generation includes text rendering, layout, and file write to internal temporary storage. No network request is made. The file is available for sharing via the Android share sheet on completion.
- **PDF Library specification:** The project uses the `pdf` package (pub.dev: pdf) with the `printing` package for share sheet integration. Justification: The `pdf` package supports custom font embedding, which is required for Telugu script rendering — most Flutter PDF libraries do not support Indic scripts without custom font embedding. The `pdf` package allows explicit TTF font embedding. Telugu rendering must be validated on Day 1 of Phase 1 — this is a go/no-go risk.
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** `pdf` package with custom font embedding confirmed working for Telugu script on the reference device before Day 4.
- **RISK:** The `pdf` package fails to render Telugu script correctly even with custom font embedding, requiring a last-minute library switch that consumes 1–2 days. Mitigation: Telugu PDF rendering is tested in a proof-of-concept on Day 1; if it fails, the team escalates immediately rather than on Day 4.

**FR-PDF.003: Patient Reference Appears on PDF, Not in Database**
- **WHAT:** The patient reference entered at export time appears in the PDF header and nowhere else in the system.
- **GIVEN:** The worker has entered a patient reference and tapped "Generate."
- **WHEN:** The PDF is generated.
- **THEN:** The patient reference string is passed directly to the PDF generation function as a parameter. It is written into the PDF document as part of the header. After the PDF file write is confirmed complete, the string is discarded — the variable holding it is set to null and is not referenced again. The string does not appear in: the local database, the sync payload, the app's log output, the screening ID, or any other persisted artifact.
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** FR-PDF.001, FR-LS.004 (what is never stored).
- **RISK:** Code review is not performed before study begins, and a developer inadvertently logs the patient reference string to a debug log that persists to a log file. Mitigation: the patient reference string handling is an explicit code review item; `print()` and `debugPrint()` calls that include the patient reference string are treated as defects.

**FR-PDF.004: PDF Contents**
- **WHAT:** Every generated PDF contains a defined set of elements and nothing else.
- **GIVEN:** PDF generation is triggered.
- **WHEN:** The PDF is created.
- **THEN:** The PDF contains:
  - **Header:** App name and version; patient reference or "[Not provided]"; date and time of screening (from captured_at); PDF filename
  - **Screening results section:** Anemia risk level label (HIGH RISK / MODERATE RISK / LOW RISK); recommended next action for anemia; Jaundice risk level label; recommended next action for jaundice; referral instruction if either is High Risk
  - **Quality notice (conditional):** If `quality_override` is true: "Note: This result was captured without passing all image quality checks. Reliability may be reduced."
  - **Disclaimer section:** Full mandatory disclaimer text, verbatim, in the active language at the time of PDF generation, in a minimum 11pt font, in a visually distinct section (bordered box or shaded background)
  - **Footer:** "Generated by AnamoAI vX.X. This is not a medical document. For use by trained ASHA workers only."
- The PDF does not contain: CIELAB values, device model, Fitzpatrick scale, or any internal identifiers.
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** FR-PDF.001–FR-PDF.003; localization strings for all PDF text elements.
- **RISK:** The PDF disclaimer text in Telugu is incorrectly translated and the error is not caught before the volunteer study. Mitigation: Telugu PDF output is reviewed by a native speaker before the volunteer study begins; this is a Project Lead coordination task.

**FR-PDF.005: PDF Filename Format**
- **WHAT:** Every generated PDF file uses the filename format `SCREEN_[YYYYMMDD]_[4-digit random ID].pdf`.
- **GIVEN:** PDF generation is complete.
- **WHEN:** The file is named before being passed to the share sheet.
- **THEN:** The filename is constructed as `SCREEN_` + date in YYYYMMDD format from captured_at + `_` + a 4-digit random alphanumeric string (not derived from patient data) + `.pdf`. Example: `SCREEN_20250127_4F2A.pdf`. The random ID is generated at PDF creation time using a cryptographically random source.
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** FR-PDF.002.
- **RISK:** Filename collision if two PDFs are generated for different patients in the same second. Mitigation: the 4-digit random ID provides 1,679,616 possible values per date — collision probability is negligible for n=20 volunteer study.

**FR-PDF.006: PDF Shared via Android Share Sheet**
- **WHAT:** The generated PDF is shared using the Android system share sheet, giving the worker the option to send via any app installed on the device.
- **GIVEN:** PDF generation is complete and the file exists in temporary internal storage.
- **WHEN:** The file is ready.
- **THEN:** The Android share sheet is invoked with the PDF file as the shared item. The worker can select WhatsApp, email, Bluetooth, or any other app available on the device. The app does not specify or restrict the sharing channel.
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** FR-PDF.002; `printing` package or equivalent share sheet integration.
- **RISK:** Android 10+ scoped storage restrictions prevent the app from sharing a file from internal storage to external apps without copying to the Downloads folder first. Mitigation: the sharing implementation uses FileProvider or the `printing` package's built-in share function, which handles scoped storage correctly; this must be tested on Android 10 and Android 14 explicitly.

---

### Feature Area 9: Cloud Sync

**FR-SY.001: Sync is Optional and Never Blocks Local Operation**
- **WHAT:** All core screening functions operate fully without network connectivity. Sync to the backend is a background operation that has no effect on local function.
- **GIVEN:** The app is installed and the local database is initialized.
- **WHEN:** Any core screening function is used (consent, white reference, capture, classification, result display, local storage, PDF generation).
- **THEN:** None of these functions make a network request or wait for a network response. Absence of connectivity produces no error, no degraded behavior, and no user-visible indication that the app is impaired. Sync is entirely separate from the core screening flow.
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** Offline state management architecture (FR-OF.001–FR-OF.004).
- **RISK:** A developer adds a connectivity check to the result screen that shows a "Sync pending" warning on the result screen itself, implying to the worker that the result is somehow incomplete. Mitigation: sync status is only displayed on a dedicated sync status screen, not on any screen in the core screening flow.

**FR-SY.002: Sync Payload Contents**
- **WHAT:** The sync payload sent to the backend contains exactly the following fields and no others.
- **GIVEN:** A sync operation is triggered.
- **WHEN:** A record is included in a sync batch.
- **THEN:** The sync payload for each record contains:
  - `screening_id` — UUID
  - `captured_at` — ISO 8601 timestamp
  - `anemia_risk` — HIGH / MODERATE / LOW
  - `jaundice_risk` — HIGH / MODERATE / LOW
  - `anemia_a_star` — float
  - `jaundice_b_star` — float
  - `quality_override` — boolean
  - `quality_gate_result` — JSON
  - `device_model` — string
  - `fitzpatrick_scale` — integer 1–6
  - `fitzpatrick_assessment_method` — SELF_REPORTED / WORKER_ASSESSED
  - `ambient_lighting` — enum
  - `sync_timestamp` — ISO 8601 timestamp of the sync event
  - `consent_recorded_at` — ISO 8601 timestamp
- The payload does NOT contain: patient reference, patient name, any identifier that could re-identify the subject, photographs, or ASHA worker personal details.
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** FR-LS.003 (local schema mirrors this); FR-SY.001 (sync does not block local).
- **RISK:** A developer includes the patient reference field in the sync payload because it's available in the PDF generation function. Mitigation: code review explicitly checks that patient reference is not passed to any sync-related function.

**FR-SY.003: Backend Authentication — API Key Required**
- **WHAT:** All sync requests to the FastAPI backend must be authenticated using a pre-shared API key.
- **GIVEN:** A sync request is initiated by the mobile client.
- **WHEN:** The request reaches the FastAPI backend.
- **THEN:** The backend validates the API key from the request header (X-API-Key). If the key is missing, invalid, or expired, the request is rejected with HTTP 401 Unauthorized. The API key is scoped to the study period and is not embedded in the mobile client in plaintext — it is loaded from a secure configuration at build time.
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** FastAPI skeleton (Phase 1 workstream); API key provisioning.
- **RISK:** API key is hardcoded in the Flutter source code and discoverable by decompilation. Mitigation: API key is loaded from a Dart define (`--dart-define`) at build time, not hardcoded; the key is rotated for the volunteer study deployment.

**FR-SY.004: Sync Conflict Resolution — Local Wins**
- **WHAT:** If a record exists on both the local device and the backend with different values, the local version is authoritative and overwrites the backend version on the next sync.
- **GIVEN:** A sync operation is in progress.
- **WHEN:** The backend has a record with the same `screening_id` but different field values compared to the local copy.
- **THEN:** The local record is sent to the backend as the authoritative copy. The backend updates its record with the local values, overwriting the existing server copy. The backend's version timestamp is updated to the local `captured_at` value. No merge or conflict resolution UI is shown to the worker — the worker never needs to resolve a sync conflict.
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** Backend API supports UPSERT semantics (POST /sync with record replacing existing).
- **RISK:** A scenario exists where the backend copy was updated by an administrator for legitimate reasons (e.g., data correction), and a local sync overwrites it. Mitigation: local-wins is the correct rule for this use case — the local copy is the source of truth because the volunteer study data is generated on-device; administrative corrections are not expected during the study period.

**FR-SY.005: Sync Status Display — Three States Only**
- **WHAT:** The worker can view sync status for records in a dedicated sync status screen, with exactly three possible states shown.
- **GIVEN:** The worker navigates to the sync status screen.
- **WHEN:** The screen is rendered.
- **THEN:** Each screening record displays one of three statuses:
  - **Synced** — record has been successfully sent to the backend
  - **Pending** — record has not yet been synced; sync will occur automatically when connectivity is available
  - **Failed** — a sync attempt was made and failed; the client will retry automatically
- No spinner, no progress bar, no "syncing..." state is shown — the status is only the final state. The sync status screen is accessible from the app's navigation but is not shown on the result screen or the home screen by default. The worker does not need to see sync status to use the app.
- **PRIORITY:** SHOULD HAVE
- **DEPENDS ON:** FR-SY.001–FR-SY.003; local sync status tracking.
- **RISK:** The sync status screen becomes a source of anxiety for the worker if "Pending" records are shown prominently. Mitigation: the sync status screen is not the default view; the worker must navigate to it. The home screen does not display a sync status indicator.

**FR-SY.006: Automatic Retry on Sync Failure**
- **WHAT:** If a sync attempt fails, the client automatically retries when connectivity is restored — no worker action is required.
- **GIVEN:** A sync attempt has failed (network error, server error, or timeout).
- **WHEN:** The app detects that network connectivity has been restored (passive network state listener, not a polling timer).
- **THEN:** The sync client automatically retries all records in the "Failed" and "Pending" states. The retry is silent — no notification is shown to the worker unless the worker explicitly views the sync status screen. Retry attempts continue with exponential backoff (initial 5 seconds, doubling up to 60 seconds) until success or until the app is closed.
- **PRIORITY:** SHOULD HAVE (can be cut to manual sync button if timeline is at risk — see Section 11)
- **DEPENDS ON:** FR-SY.001–FR-SY.005; network state listener implementation.
- **RISK:** Automatic retry consumes battery on low-end devices if the device is in a poor connectivity area and retrying repeatedly. Mitigation: retry timer is capped at 60 seconds; if the device is in a no-connectivity area, the app stops retrying after 10 failed attempts (across all records, not per-record) until the next time the app is opened.

---

### Feature Area 10: Offline Operation

**FR-OF.001: All Core Functions Work with Zero Connectivity**
- **WHAT:** Every function in the core screening flow works completely offline: consent, white reference, capture, quality gate, analysis, classification, result display, local storage, PDF generation.
- **GIVEN:** The app is installed on the device.
- **WHEN:** The device has no internet connectivity (airplane mode, no signal, or no Wi-Fi).
- **THEN:** All core screening functions operate identically to the online case. No screen in the core flow shows an error message that implies internet is required. No function hangs, times out, or degrades due to absence of connectivity.
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** FR-CA.001–FR-CA.005, FR-QG.001–FR-QG.007, FR-AI.001–FR-AI.006, FR-RD.001–FR-RD.006, FR-LS.001–FR-LS.006, FR-PDF.001–FR-PDF.006.
- **RISK:** A network library or package used in the app (e.g., for analytics or crash reporting) makes a blocking network call on the main thread, causing the UI to freeze when offline. Mitigation: the app uses no analytics SDK; any crash reporting library must be configured to be non-blocking and silent on network failure. This is verified during Phase 2 testing in airplane mode.

**FR-OF.002: No Error State Implies Internet is Required**
- **WHAT:** No screen in the core screening flow displays an error message that suggests internet connectivity is required for normal operation.
- **GIVEN:** The device is offline.
- **WHEN:** Any screen in the core screening flow is rendered.
- **THEN:** No error message referencing network connectivity, internet, Wi-Fi, or "connection" appears on the screen. If the app encounters a condition that would normally be resolved by internet (e.g., sync), it handles it silently or displays a neutral status indicator (e.g., "Sync pending" on the sync status screen only — not on the result screen).
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** FR-OF.001; UX review of all error states.
- **RISK:** A developer reuses a generic error message component that includes a default "Check your internet connection" string for all errors. Mitigation: all error strings in the core screening flow are custom-written and reviewed for offline appropriateness.

**FR-OF.003: Sync-Related UI Hidden or Disabled When Offline**
- **WHAT:** When offline, the app does not show any sync-related UI elements on the core screening screens.
- **GIVEN:** The device is offline.
- **WHEN:** The app is in the core screening flow (consent through result display and PDF generation).
- **THEN:** No button, indicator, or text referencing sync appears on any core screening screen. Sync UI (sync status screen, sync settings) is accessible via navigation but does not show error states — it shows the current sync status (Pending / Synced / Failed) without implying that the offline state is a problem.
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** FR-OF.001; UI/UX designer wireframes for sync status screen.
- **RISK:** A developer adds a "Sync Now" button to the home screen that is visible even when offline, causing the worker to tap it and see a network error. Mitigation: the "Sync Now" button is only visible in the dedicated sync status screen, and it is disabled with a neutral message ("Connectivity required") not an error state.

**FR-OF.004: Sync Queue Persists Across App Restarts**
- **WHAT:** The sync queue — the list of records waiting to be synced — persists across app restarts and is restored when the app is reopened.
- **GIVEN:** Records are in the sync queue (Pending or Failed state).
- **WHEN:** The app is closed and reopened.
- **THEN:** The sync queue is reloaded from the local database. Any records that were pending before the app closed are still pending on reopen. Sync retries resume when connectivity is detected after app reopen. No records are lost because the app was closed before sync completed.
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** FR-LS.001 (records stored locally); FR-LS.003 (sync_status field in schema).
- **RISK:** The sync queue is an in-memory list that is not rebuilt from the database on app reopen. Mitigation: sync queue is built from the database query `SELECT * FROM screening_records WHERE sync_status IN ('PENDING', 'FAILED')` at app start — not from an in-memory cache.

---

### Feature Area 11: Localization

**FR-L11.001: Language Options — Telugu, Hindi, English**
- **WHAT:** The app supports three languages: Telugu (MUST HAVE), Hindi (MUST HAVE), and English (default fallback).
- **GIVEN:** The app is installed on the device.
- **WHEN:** The app is launched for the first time or the user navigates to language settings.
- **THEN:** The language selection screen (FR-CS.001) or language settings screen displays three options: Telugu, Hindi, English. Each language is labeled in its own script. All three options are selectable. English is the fallback language — if a string is missing in Telugu or Hindi, the English string is displayed instead (with a warning logged during development).
- **PRIORITY:** MUST HAVE (both Telugu and Hindi are MUST HAVE for the study)
- **DEPENDS ON:** Localization framework in Flutter (using `flutter_localizations` or equivalent).
- **RISK:** The 14-day timeline does not allow both Telugu and Hindi translations to be completed and reviewed. Mitigation: see Section 12, Q2 for the cut decision. If one language must be cut, Telugu ships first, Hindi is added in a post-study update.

**FR-L11.002: Language Selection on First Launch, Changeable in Settings**
- **WHAT:** Language is selected on first launch and can be changed later in the app's settings screen.
- **GIVEN:** The app is launched for the first time (FR-CS.001).
- **WHEN:** The user selects a language on the first launch screen.
- **THEN:** The selected language is stored in shared preferences. On subsequent launches, the app loads the stored language and does not re-present the language selection screen. The user can change the language at any time from the app's settings screen. When the language is changed, the app reloads the current screen (or navigates to the home screen) with the new language applied.
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** FR-L11.001; Flutter localization package.
- **RISK:** Language change does not apply to the current screen until the app is restarted. Mitigation: use a `Consumer` or `Provider` pattern that rebuilds the widget tree when the locale changes; test this explicitly.

**FR-L11.003: All Worker-Facing Text Translated**
- **WHAT:** All text visible to the ASHA worker is translated into Telugu and Hindi, including navigation, instructions, result labels, error messages, disclaimer, and consent screen.
- **GIVEN:** A language other than English is selected.
- **WHEN:** Any screen in the core screening flow is rendered.
- **THEN:** All worker-facing text appears in the active language. This includes:
  - Navigation labels and button text
  - Instructions (white reference, capture guidance, quality gate guidance)
  - Result labels (High Risk / Moderate Risk / Low Risk)
  - Recommended actions (referral instructions)
  - Error messages and guidance text
  - The mandatory disclaimer (locked text — see FR-RD.005)
  - Consent screen content
  - PDF generation screen text
- Text that is not translated: app name (proper noun), version number, and any technical identifiers that do not have a meaningful translation.
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** FR-L11.001; localization string files for Telugu and Hindi.
- **RISK:** The Telugu and Hindi translations are incomplete or inaccurate, leading to worker confusion. Mitigation: all translated strings are reviewed by a native Telugu and Hindi speaker before the volunteer study begins. This is a Project Lead coordination task.

**FR-L11.004: No Medical Terminology Without Plain Language Equivalent**
- **WHAT:** Any medical term used on a worker-facing screen must be accompanied by a plain language equivalent on the same screen.
- **GIVEN:** A screen in the core screening flow contains a medical term (e.g., "conjunctiva," "sclera," "hemoglobin," "bilirubin").
- **WHEN:** The screen is rendered.
- **THEN:** The medical term appears with a plain language explanation on the same screen, or the term is replaced entirely with the plain language equivalent. For example, instead of "Conjunctival pallor detected," the screen shows "Pale inside of eyelid detected." The UI/UX designer must validate that no screen contains a medical term without a plain language equivalent.
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** UI/UX designer wireframes reviewed for medical terminology; localization strings reflect plain language.
- **RISK:** A developer writes UI text that includes medical terminology because it appears in the classification logic. Mitigation: the UI/UX designer and Project Lead review all worker-facing text strings for medical terminology before the volunteer study begins.

**FR-L11.005: Icon-Driven Navigation as Primary UI Pattern**
- **WHAT:** Every navigation action in the core screening flow has an icon as its primary visual element; text labels are secondary.
- **GIVEN:** A screen in the core screening flow contains a navigation action (button, tab, or other tappable element).
- **WHEN:** The screen is rendered.
- **THEN:** The navigation element has:
  - A distinctive icon that communicates its function without text
  - A text label in the active language (secondary — smaller font, below or beside the icon)
- The icon is the first visual element the worker sees. The icon alone must be sufficient to understand the action. The text label provides confirmation. This is a literacy accommodation — workers with limited reading fluency can navigate by icon recognition.
- **PRIORITY:** MUST HAVE
- **DEPENDS ON:** Icon set designed by UI/UX designer; Flutter icon widgets used throughout navigation.
- **RISK:** Icon set is not designed before Flutter Developer 1 implements navigation, leading to placeholder icons that are not intuitive. Mitigation: UI/UX designer completes icon design for all navigation actions by Day 4 (Phase 1 deliverable).

---

## 7. NON-FUNCTIONAL REQUIREMENTS

### Performance

- **AR at 20 FPS minimum** on Snapdragon 665, 4GB RAM, Android 10+ in indoor ambient light. Measured over 30-second continuous session. Hard pass/fail.
- **Classification under 3 seconds** from capture confirmation to result display on reference device. Hard pass/fail.
- **PDF generation under 5 seconds** from "Generate" tap to file available for sharing on reference device. Hard pass/fail.
- **Cold start under 4 seconds** from icon tap to language selection screen rendered on reference device. Hard pass/fail.

### Degradation

- If FPS drops below 15 for more than 3 consecutive seconds on lower-spec devices: app reduces overlay complexity. If FPS does not recover to ≥ 15 within 5 seconds, dynamic overlay is disabled and replaced with static positioning guide. Quality gating continues. This is a SHOULD HAVE.
- Frame rate measurement utility must not consume sufficient CPU to worsen the degradation it is detecting. Mitigation: frame rate measured at widget level, not via performance profiling API.

### Crash Recovery

- If app crashes mid-capture (between capture button tap and result display), no partial result is saved. Session resets. Worker is returned to session start screen (white reference capture). This assumes the crash occurred before the atomic database write (FR-LS.001). If the crash occurs after the atomic write, the record exists and sync proceeds normally.
- Crash reporting is silent and non-blocking. No crash reporting SDK that transmits data without explicit consent is used.

### Sync Failure

- Local data is never affected by sync failure. The local record is the authoritative copy. Sync failure does not alter or corrupt the local record.
- Retry is automatic and silent. No worker action required.
- Sync status: Synced, Pending, Failed — only on dedicated sync status screen, not on core screening screens.

### Security

- **AES-256 local database encryption** using sqflite_sqlcipher or equivalent. Encryption key stored in Android Keystore, not hardcoded.
- **No analytics SDK** that transmits device or usage data.
- **API key authentication** for all backend sync requests. Key loaded from secure build configuration, not hardcoded.
- **No patient data stored** beyond the allowed fields in FR-LS.003. Patient reference exists only on PDF, never in database or sync payload.

### Compatibility

- **Android 8.0 (API level 26) minimum.** Test on Android 8.0 emulator and physical device if available.
- **Tested on Android 10, 12, 14.** The 14-day timeline does not allow testing on every Android version; these three are the minimum coverage.
- **8MP rear camera minimum.** Test on reference device (Snapdragon 665, 4GB RAM, typical camera module for that processor class).
- **APK sideloading** is the expected distribution method. The app is not on Play Store for the study period. Build process produces an APK that can be installed via `adb install` or file manager.

### Battery

- **Full screening session under 2% battery** on reference device. A full session is defined as: language select → consent → white reference → capture → result → PDF generation. Measured with the device screen at 50% brightness, no other apps running.
- No background processes that consume battery when the app is not in use (except sync retry, which is event-driven, not polling).

---

## 8. TECHNICAL ARCHITECTURE

### Technology Stack Overview

| Component | Technology | Owner |
|-----------|------------|-------|
| Mobile frontend | Flutter / Dart | Flutter Dev 1, Flutter Dev 2 |
| Face mesh tracking | google_mlkit_face_mesh_detection | ML/CV Engineer |
| CIELAB analysis | Dart implementation (custom) | ML/CV Engineer |
| Local storage | sqflite with sqflite_sqlcipher | Flutter Dev 2 |
| PDF generation | pdf package (pub.dev) | Flutter Dev 1 |
| Backend | FastAPI (Python 3.10+) | Backend Developer |
| Database | PostgreSQL | Backend Developer |
| Sync protocol | HTTPS REST API | Backend Developer |

---

### Technology Choices and Justifications

**Flutter / Dart**
- **CHOICE:** Flutter 3.x, Dart 3.x
- **JUSTIFICATION:** Flutter provides a single codebase for Android APK. The 14-day timeline and 6-person team cannot support separate native Android and iOS builds. Flutter's hot reload accelerates iteration during Phase 2. Flutter's widget-based architecture maps well to the icon-driven UI required for low-literacy users. Flutter supports custom font embedding (required for Telugu rendering) across both the app UI and the PDF generation library. The team has Flutter experience.
- **OWNER:** Flutter Developer 1, Flutter Developer 2
- **DEPENDENCY RISK:** Flutter's camera plugin (`camera`) may not support all Android devices equally, particularly older devices (Android 8.0). The camera preview may have latency on low-end devices.
- **MITIGATION:** The `camera` plugin is tested on the reference device and an Android 8.0 emulator during Phase 1. If camera latency exceeds acceptable limits, the ML/CV Engineer reduces overlay complexity before other mitigations.

**google_mlkit_face_mesh_detection**
- **CHOICE:** google_mlkit_face_mesh_detection (pub.dev), pinned version
- **JUSTIFICATION:** Google's ML Kit provides hardware-accelerated face mesh tracking on Android, which is required for 20+ FPS on the reference device. The face mesh provides the 468 landmark points needed for eye ROI extraction (indices 33, 133, 159, 145 for left eye; 362, 263, 386, 374 for right eye). ML Kit runs entirely on-device, satisfying the offline-first constraint. No cloud API call means zero per-inference cost. The package is maintained by Google and has community support.
- **OWNER:** ML/CV Engineer
- **DEPENDENCY RISK:** Google has deprecated previous ML Kit APIs (e.g., Firebase ML Kit). The package version may break with Flutter updates.
- **MITIGATION:** The version is pinned in `pubspec.yaml`. The team does not use `latest`. The Phase 1 MediaPipe proof-of-concept validates the package works on the reference device before Phase 2 begins.

**sqflite with sqflite_sqlcipher**
- **CHOICE:** sqflite + sqflite_sqlcipher for AES-256 encryption
- **JUSTIFICATION:** sqflite is the most widely used Flutter SQLite package. It supports Android 8.0 and has a stable API. sqflite_sqlcipher provides AES-256 encryption at rest, which is required for health data stored on a device that may be lost or stolen. The encrypted database is the only persistent local storage mechanism — no shared preferences for sensitive data. The package supports atomic transactions (FR-LS.001).
- **OWNER:** Flutter Developer 2
- **DEPENDENCY RISK:** sqflite_sqlcipher may have compatibility issues with Android 8.0 or with specific device architectures (armeabi-v7a vs. arm64-v8a).
- **MITIGATION:** Encryption library compatibility is tested on Android 8.0 emulator and the reference device as a Phase 1 task. If sqflite_sqlcipher fails, the fallback is to use `flutter_secure_storage` for the encryption key and standard sqflite with manual encryption — but this is a riskier approach. The Phase 1 test determines the path.

**FastAPI (Python)**
- **CHOICE:** FastAPI, Python 3.10+
- **JUSTIFICATION:** FastAPI provides automatic OpenAPI documentation, which simplifies API client generation for the Flutter team. FastAPI is async by default, supporting concurrent sync requests from multiple devices. The sync endpoint is simple (POST /sync with JSON payload), so the overhead of FastAPI is minimal. Python is familiar to the Backend Developer and allows rapid iteration on the sync API. The backend is deployed for the study period only — a lightweight framework is appropriate.
- **OWNER:** Backend Developer
- **DEPENDENCY RISK:** The backend requires a hosting environment for the study period. Deployment may be blocked by institutional IT policies.
- **MITIGATION:** The backend can run on a local machine or on a cloud free tier (Render, Fly.io, or Railway) for the study period. A fallback is to run the backend locally on the Project Lead's laptop with ngrok for external access. The sync API is simple enough that it can be mocked for the demo if deployment is blocked.

**PostgreSQL**
- **CHOICE:** PostgreSQL 15+
- **JUSTIFICATION:** PostgreSQL is the standard relational database for FastAPI. It supports JSON fields (for `quality_gate_result`), which simplifies storage of structured quality gate data. PostgreSQL supports the required schema (UUID primary key, timestamp fields, enums). The study dataset is small (n=20, < 100 records), so performance is not a concern. The choice is driven by ecosystem compatibility with FastAPI (SQLAlchemy or asyncpg).
- **OWNER:** Backend Developer
- **DEPENDENCY RISK:** PostgreSQL requires a hosting environment separate from the FastAPI backend (or can be co-located on the same instance). This doubles the deployment complexity.
- **MITIGATION:** For the study period, PostgreSQL can run in a Docker container alongside FastAPI on the same cloud instance. If deployment complexity is a concern, SQLite can be used for the backend instead — the dataset is small enough that SQLite is sufficient. This is an open decision tracked in Section 12, but the default is PostgreSQL.

**PDF Generation Library — pdf package**
- **CHOICE:** `pdf` package (pub.dev) version 3.10.4+ with custom font embedding
- **JUSTIFICATION:** The `pdf` package is the only Flutter PDF library that reliably supports custom font embedding for non-Latin scripts, including Telugu and Hindi. Other libraries (e.g., `printing`) generate PDFs but do not support custom fonts, resulting in blank boxes for Telugu characters. The `pdf` package allows explicit TTF font embedding and has been used successfully for Indic scripts in community examples. The package generates PDFs entirely on-device, satisfying the offline-first constraint.
- **OWNER:** Flutter Developer 1
- **DEPENDENCY RISK:** The `pdf` package may not render Telugu script correctly even with custom font embedding, due to complex shaping requirements (Telugu is a Brahmic script with conjunct characters and vowel modifiers).
- **MITIGATION:** Telugu PDF rendering is tested in a proof-of-concept on Day 1 of Phase 1. If the `pdf` package fails, the team escalates to the Project Lead immediately. The fallback is to generate a plain text report (TXT) instead of PDF — but this reduces the professional appearance of the referral document. The Phase 1 test determines the path. If the `pdf` package works, the risk is resolved.

---

### Data Flow — Numbered Sequence

1. Worker opens app. Language selection screen displayed (FR-CS.001).
2. Worker selects language. Language preference stored.
3. Worker initiates session. Consent screen displayed in active language (FR-CS.002).
4. Worker consents. Consent event written to local encrypted database with timestamp (FR-CS.003).
5. White reference capture screen displayed. Worker photographs white surface (FR-WR.001).
6. App validates white reference image: brightness, neutrality, non-overexposure (FR-WR.002).
7. If valid: white-patch gains calculated and stored in session object (FR-WR.004).
8. If invalid: specific corrective guidance displayed; worker retries (FR-WR.003).
9. White reference accepted. App advances to eye capture screen.
10. Face mesh tracking initializes using google_mlkit_face_mesh_detection (FR-CA.001).
11. AR overlay displayed: positioning guide, quality gate indicators (FR-CA.002).
12. Quality gate evaluates each frame: blur (Laplacian variance > 100), exposure (mean 40–200), eye openness (EAR > 0.2) (FR-QG.001–FR-QG.003).
13. All three gates pass simultaneously. Capture button enables (FR-QG.004).
14. Worker taps capture button. Image captured from the frame that triggered the enable state.
15. Face mesh landmarks from capture frame used to extract conjunctival ROI and scleral ROI (FR-CA.003).
16. White-patch gains applied to both ROIs (FR-WR.004).
17. CIELAB conversion performed on both ROIs (FR-AI.001).
18. a* value from conjunctival ROI compared to thresholds: High Risk < 5, Moderate 5–10, Low ≥ 10 (FR-AI.002).
19. b* value from scleral ROI compared to thresholds: High Risk ≥ 15, Moderate 10–15, Low < 10 (FR-AI.003).
20. Both classifications generated in same pass (FR-AI.004). Classification completes in < 3 seconds (FR-AI.005).
21. Result screen displayed: both risk labels with color and icon, recommended actions, mandatory disclaimer (FR-RD.001–FR-RD.006).
22. If either result is High Risk: prominent referral instruction displayed (FR-RD.004).
23. Worker taps "Generate PDF." PDF generation screen displayed.
24. Worker enters patient reference (name or household ID) — optional (FR-PDF.001).
25. Worker taps "Generate." PDF generated locally in < 5 seconds (FR-PDF.002).
26. Patient reference written to PDF header, then discarded from memory. Not saved to database (FR-PDF.003).
27. PDF shared via Android share sheet (FR-PDF.006).
28. Result written to local encrypted database atomically (FR-LS.001).
29. Sync queue updated with record status PENDING (FR-SY.005).
30. Worker exits session. Session complete.
31. When connectivity available: sync client detects network state change.
32. Sync payload sent to backend: contains screening_id, captured_at, anemia_risk, jaundice_risk, anemia_a_star, jaundice_b_star, quality_override, quality_gate_result, device_model, fitzpatrick_scale, fitzpatrick_assessment_method, ambient_lighting, sync_timestamp, consent_recorded_at — NOT patient reference (FR-SY.002).
33. Backend authenticates API key (FR-SY.003). If valid, record stored.
34. Local sync status updated to SYNCED. If sync fails, status updated to FAILED; automatic retry on connectivity restore (FR-SY.006).
35. 30 days after capture: automatic deletion from local database (FR-LS.005). Backend follows independent deletion schedule.

---

## 9. CONSTRAINTS AND KNOWN LIMITATIONS

### Limitation 1: Cross-Device Camera Sensor Variance

**LIMITATION:** Different Android devices have different camera sensors, color processing pipelines, and white balance algorithms. The CIELAB values computed from the same eye may vary across devices.

**WHY:** The app does not perform device-specific calibration. The white-patch gain correction corrects for ambient lighting but does not correct for sensor-to-sensor differences in color response or camera pipeline color processing.

**MITIGATION IN V1:** The study logs the device model for every screening record. The analysis can stratify results by device model to identify systematic bias. The study report presents accuracy figures with the caveat that they are specific to the device models used in the study.

**RESOLUTION IN V2:** Device-specific calibration profiles — a reference image set captured on each device model and used to correct the CIELAB conversion pipeline. This requires a calibration procedure for each new device model, which is not feasible within the 14-day timeline.

**EVALUATOR NOTE:** This limitation does not invalidate the proof-of-concept. The study is measuring feasibility on consumer hardware, not performance across all devices. The device model confounder is logged and can be controlled for in analysis. The study will show whether the method works on the specific devices used in the study.

---

### Limitation 2: White-Patch Gain Scope

**LIMITATION:** White-patch gain normalization corrects for ambient lighting color (the color of the light source) but does not correct for sensor differences or for non-neutral white reference surfaces.

**WHY:** The white-patch method assumes a neutral white reference surface and a linear camera response. Consumer Android cameras do not have perfectly linear responses. The white reference surface (plain A4 paper) may vary in color across batches.

**MITIGATION IN V1:** The study protocol specifies that reference paper must be matte white A4 or equivalent. The white reference validity criteria (brightness ≥ 180, neutrality ≤ 15, non-overexposure) ensure the paper is reasonably neutral. The CIELAB thresholds are compared to the corrected values, so systematic bias from the white-patch method is accounted for in the correlation analysis.

**RESOLUTION IN V2:** Use a color calibration card with known reference colors instead of plain white paper. This would provide more accurate color correction but introduces a consumable cost and requires the ASHA worker to carry the card.

**EVALUATOR NOTE:** White-patch normalization is a standard color correction technique used in computer vision. The study will measure the correlation between the corrected values and ground truth, which accounts for the limitations of the white-patch method.

---

### Limitation 3: Pulse Oximetry Proxy Validity at Moderate Tier

**LIMITATION:** Pulse oximetry (SpO₂) is an unreliable proxy for moderate anemia. SpO₂ remains normal (95–100%) until hemoglobin drops to approximately 7–8 g/dL (severe anemia). Moderate anemia (hemoglobin 8–10.9 g/dL) is not reliably detected by SpO₂.

**WHY:** The study's fallback ground truth for anemia is pulse oximetry when clinic hemoglobinometer records are unavailable. This means moderate-tier anemia classifications have materially weaker ground truth validation than high-tier classifications.

**MITIGATION IN V1:** This is a named limitation (see Section 3 — NAMED LIMITATION — MODERATE ANEMIA TIER VALIDATION). The study report presents moderate-tier accuracy separately with an explicit caveat. The analysis may collapse to a binary High / Not-High classification for the primary correlation if the moderate-tier data is insufficient.

**RESOLUTION IN V2:** Use clinic hemoglobinometer records as ground truth for all volunteers. This requires establishing partnerships with PHCs before the study begins and ensuring the screening session occurs within 48 hours of the clinic test.

**EVALUATOR NOTE:** The study is a feasibility proof-of-concept. The moderate-tier limitation is acknowledged. The high-tier anemia results have ground truth support from pulse oximetry, and clinic records will be obtained where possible. The study will show whether the tool can detect severe anemia (high risk) — which is the most clinically urgent tier.

---

### Limitation 4: n=20 Statistical Power

**LIMITATION:** The study sample size (n=20) is minimally adequate to detect a large correlation (r > 0.7) with α=0.05 and power=0.80. It is not powered to detect moderate correlations, subgroup effects, or to establish clinical diagnostic accuracy.

**WHY:** The 14-day timeline and volunteer availability limit the sample size to 20.

**MITIGATION IN V1:** The study report explicitly states what the sample size can and cannot detect. No claims of clinical accuracy are made. Confidence intervals are reported for all correlation coefficients.

**RESOLUTION IN V2:** A larger validation study with n=100+ volunteers, powered to detect moderate correlations and subgroup effects.

**EVALUATOR NOTE:** The study is a feasibility proof-of-concept, not a clinical validation trial. n=20 is sufficient to demonstrate the method works on consumer hardware with Indian skin tones. The team can use the n=20 results to justify a larger study in future work.

---

### Limitation 5: Skin Tone as Uncontrolled Confounder

**LIMITATION:** Skin tone (Fitzpatrick scale I–VI) may confound the CIELAB values, particularly for the scleral ROI where the boundary between sclera and skin may introduce non-scleral pixels.

**WHY:** The face mesh landmark-based ROI extraction does not perfectly segment the sclera — it uses a fixed bounding box that may include skin pixels for subjects with deep-set eyes or narrow palpebral fissures. The Fitzpatrick scale is logged but the sample size (n=20) is not powered for subgroup analysis.

**MITIGATION IN V1:** Fitzpatrick scale is logged as a confounder for every record. The study report presents the correlation with and without Fitzpatrick scale as a covariate. The analysis notes that skin tone may affect the absolute CIELAB values but the correlation with ground truth is the primary metric.

**RESOLUTION IN V2:** Use a more sophisticated sclera segmentation model (e.g., RITnet or a custom U-Net) trained on a diverse dataset to isolate the sclera from skin and iris. This is out of scope for v1 (see Section 10).

**EVALUATOR NOTE:** The study is measuring correlation, not absolute accuracy. If the correlation is strong (r > 0.7), it suggests the signal is detectable despite the confounding. The skin tone confounder is logged and can be controlled for in future work.

---

### Limitation 6: No Device-Specific Calibration Profiles

**LIMITATION:** The app does not have calibration profiles for different device models. The CIELAB conversion uses the same parameters for all devices.

**WHY:** Calibration profiles require a reference image set captured on each device model, which is not feasible within the 14-day timeline.

**MITIGATION IN V1:** The study uses a limited set of device models (reference device and maybe 1–2 others). The analysis reports accuracy for each device model separately if sufficient data exists. The white-patch normalization reduces device-to-device variability but does not eliminate it.

**RESOLUTION IN V2:** Device-specific calibration profiles (see Limitation 1).

**EVALUATOR NOTE:** This is a limitation of any smartphone-based colorimetric system. The study's use of the reference device as the primary testing platform means the results are valid for that device. Generalizing to other devices is a v2 goal.

---

### Limitation 7: No ABDM Integration

**LIMITATION:** The app does not integrate with India's Ayushman Bharat Digital Mission (ABDM) infrastructure, including the ABHA (Ayushman Bharat Health Account) patient identifier and the Health Records component.

**WHY:** ABDM integration requires additional development time, compliance with the ABDM API specifications, and institutional approval. The 14-day timeline does not support this.

**MITIGATION IN V1:** The app uses a patient reference entered at PDF generation time (name or household ID) as a local identifier. This reference is not stored or synced. The app is a self-contained screening tool that does not rely on ABDM infrastructure.

**RESOLUTION IN V2:** Integrate with ABDM: generate or update ABHA records, push screening results to the patient's Health Records, and use ABHA identifiers instead of local patient references. This would align the tool with India's national digital health strategy.

**EVALUATOR NOTE:** ABDM integration is a future enhancement, not a core requirement for the proof-of-concept. The app's privacy-preserving approach (no patient data stored locally) is compliant with current regulations. The team should be prepared to discuss ABDM integration in the pitch deck as a future roadmap item.

---

## 10. OUT OF SCOPE — VERSION 1

### Feature: Skin Lesion Analysis

**FEATURE:** Analysis of skin lesions, rashes, or other dermatological conditions using the same camera capture pipeline.

**WHY EXCLUDED FROM V1:** The app's scope is specifically anemia and neonatal jaundice screening. Adding skin lesion analysis would require separate validation, thresholds, and medical disclaimers. The regulatory status would change — skin lesion analysis is a different medical domain with different risks and liability considerations. The 14-day timeline cannot support a second condition beyond the two already included.

**V2 TRIGGER:** If the volunteer study demonstrates the feasibility of the camera-based screening approach, skin lesion analysis could be added as a separate module in v2 or v3.

---

### Feature: Teeth Wellness Screening

**FEATURE:** Analysis of dental health using the camera, similar to optical screening for anemia and jaundice.

**WHY EXCLUDED FROM V1:** Not within the scope of the SIH problem statement. Anemia and neonatal jaundice are the specified health conditions. The team has no dental health expertise.

**V2 TRIGGER:** Not planned. This is outside the product vision.

---

### Feature: RITnet Sclera Segmentation

**FEATURE:** Use RITnet (or a similar deep learning model) for sclera segmentation instead of the fixed landmark-based ROI extraction.

**WHY EXCLUDED FROM V1:** RITnet is a deep learning model that would require running on-device inference for every frame, which is computationally expensive. The reference device (Snapdragon 665) may not support it at 20 FPS. The model would require training on diverse eye images, which the team does not have access to. The current landmark-based approach is simpler and is sufficient for the proof-of-concept.

**V2 TRIGGER:** If the volunteer study shows that sclera segmentation is a significant source of error, RITnet or a similar model could be considered for v2. This would require additional ML/CV expertise and computational resources.

---

### Feature: Device-Specific Calibration Profiles

**FEATURE:** Calibration profiles for different device models, correcting for sensor-to-sensor color response differences.

**WHY EXCLUDED FROM V1:** Calibration requires capturing a reference image set on each device model, which is not feasible within the 14-day timeline. The study uses a limited set of device models, so device-specific calibration is not required for the proof-of-concept.

**V2 TRIGGER:** If the tool is to be deployed on a wider range of devices, device-specific calibration profiles would be required to maintain accuracy across devices.

---

### Feature: ABDM / ABHA Integration

**FEATURE:** Integration with India's Ayushman Bharat Digital Mission (ABDM) infrastructure, including ABHA patient identifiers and Health Records.

**WHY EXCLUDED FROM V1:** ABDM integration requires additional development time, compliance with specifications, and institutional approval. The 14-day timeline does not support this. The tool is a self-contained screening device for the volunteer study.

**V2 TRIGGER:** If the tool moves to deployment in the public health system, ABDM integration would be required to align with India's national digital health strategy. This is a priority for v2.

---

## 11. PHASED IMPLEMENTATION PLAN

### Phase 1 — Days 1 to 4

| Workstream | Owner | Deliverable |
|------------|-------|-------------|
| Pitch deck and positioning | Project Lead | Draft pitch deck ready for faculty review by Day 4 |
| UI wireframes and AR overlay design | UI/UX Designer | Complete wireframes for all core screening screens; AR overlay visual design approved by Project Lead |
| Consent form drafting and ethics logistics | Project Lead | Consent form drafted, reviewed by faculty supervisor, approved by Day 4 |
| Flutter project scaffold and navigation | Flutter Dev 1 | Project scaffolded; navigation between all core screens wired; language selection implemented |
| MediaPipe integration proof-of-concept | ML/CV Engineer | Face mesh tracking running on reference device at target FPS; ROI extraction proof-of-concept working |
| FastAPI skeleton and authentication setup | Backend Dev | FastAPI skeleton with /sync endpoint; API key authentication working on localhost |
| Database schema design | Backend Dev + Flutter Dev 2 | PostgreSQL schema designed; sqflite schema design matching local storage requirements |

**GO/NO-GO CRITERIA TO ENTER PHASE 2:**

These are the real gates — not process milestones:

- [ ] **MediaPipe tracking confirmed running at 20+ FPS on the reference device.** This is the highest technical risk. If ML Kit cannot achieve 20 FPS on Snapdragon 665, the AR guidance cannot meet the performance target. The ML/CV Engineer must demonstrate this by end of Day 4.
- [ ] **White reference normalization tested on at least 2 different Android devices and producing stable gain values.** The white-patch method must work on the reference device and at least one other device. If gain values vary by > 10% between devices on the same reference surface, the method needs revision.
- [ ] **Ethics consent form reviewed and approved by faculty supervisor.** The volunteer study cannot begin without approved consent documentation. The Project Lead must have this signed off by Day 4.
- [ ] **Telugu or Hindi string file at least 50% complete.** Localization is a significant effort. If translations are less than 50% complete by Day 4, the UI will not be ready for the volunteer study. The UI/UX Designer and Project Lead coordinate this.
- [ ] **API key authentication working end-to-end on localhost.** The sync API must be secured. The Backend Developer must demonstrate that an unauthenticated sync request is rejected and an authenticated request succeeds.

**If any of these are not met by end of Day 4, the team escalates — does not proceed and hope.** The Project Lead must communicate the gap to the faculty supervisor and propose a mitigation or rescope the plan.

---

### Phase 2 — Days 5 to 14

**Sequence the work in dependency order:**

| Days | Workstream | Owner | Dependency |
|------|------------|-------|------------|
| 5–6 | AR capture pipeline complete and tested | Flutter Dev 1 + ML/CV Engineer | Phase 1 MediaPipe PoC must be working |
| 5–6 | Quality gating logic implemented | ML/CV Engineer | AR capture pipeline available |
| 7–8 | Quality gating integrated and tested on 3 different devices | Flutter Dev 1 + ML/CV Engineer | Quality gating logic complete |
| 8–9 | White reference normalization integrated | ML/CV Engineer | AR capture pipeline complete |
| 9–10 | CIELAB analysis and classification integrated and tested against known reference images | ML/CV Engineer | White reference normalization complete |
| 10–11 | Local storage, encryption, and PDF generation | Flutter Dev 2 + Flutter Dev 1 | Classification complete; PDF library confirmed working |
| 11–12 | Volunteer study execution (n=20) | Project Lead + All team members | All core features integrated and tested |
| 12–13 | Results analysis and accuracy reporting | ML/CV Engineer + Project Lead | Volunteer study data collected |
| 13–14 | Cloud sync, demo polish, documentation finalization | Backend Dev + Flutter Dev 2 + Project Lead | Results analysis complete; sync API available |

**Parallel workstreams during Phase 2:**

- UI/UX Designer: finalizes any remaining UI polish (icons, spacing, color contrast) and documents the design decisions
- Project Lead: coordinates volunteer scheduling, ensures consent forms are signed, manages logistics for the study execution
- Backend Developer: deploys the FastAPI backend to a hosting environment, tests sync from the mobile client

---

### Cut Priority List if Timeline Slips

**CANNOT CUT — demo breaks without these:**

- AR capture and quality gating (FR-CA.001–FR-CA.005, FR-QG.001–FR-QG.007)
- CIELAB classification (FR-AI.001–FR-AI.006)
- Result display with disclaimer (FR-RD.001–FR-RD.006)
- Local storage (FR-LS.001–FR-LS.006)
- PDF generation (FR-PDF.001–FR-PDF.006)

**CAN MOCK FOR DEMO — cut if needed:**

- Cloud sync (FR-SY.001–FR-SY.006): Show sync status UI with mocked backend response. The demo audience does not need to see live data flowing to the backend.
- District manager dashboard: This is a SHOULD HAVE for v1. If the timeline is tight, the dashboard is deferred entirely. The data exists in the backend and can be accessed via PostgreSQL query for the study team.

**CAN CUT ENTIRELY — does not affect core demo:**

- Hindi localization (FR-L11.001): Ship Telugu + English only for the volunteer study. Hindi can be added in a post-study update if needed for the pitch deck.
- Manual override for quality gate (FR-QG.006): For the volunteer study, the quality gate can be a hard gate with no override. The study is measuring accuracy under ideal conditions; manual override introduces uncontrolled variability.
- Automatic sync retry logic (FR-SY.006): A manual "Sync Now" button is acceptable for the volunteer study. The study team can manually sync records after data collection.

---

## 12. OPEN QUESTIONS AND DECISIONS REQUIRED

### Q1: Moderate Anemia Tier Validation Gap

**QUESTION:** The pulse oximetry proxy does not reliably detect moderate anemia. The moderate-risk tier has weaker ground truth than the high-risk tier. Decision: report moderate-tier accuracy separately with explicit caveat, or collapse to a binary High / Not-High for the validation study?

**OWNER:** ML/CV Engineer + Project Lead
**DEADLINE:** Day 5 (before volunteer study execution)
**DEFAULT:** Report separately with caveat
**RISK IF DEFAULT IS WRONG:** Binary classification may understate the tool's sensitivity at moderate risk, while separate reporting may produce an accuracy figure that appears weaker than it should be due to the ground truth proxy limitation.

**DISCUSSION:** The Moderate Risk tier is clinically meaningful — it identifies women with hemoglobin 8–10.9 g/dL who need monitoring and early referral. Collapsing to binary would lose this distinction. However, reporting moderate-tier accuracy with a weak ground truth proxy may be misleading. The safest approach is to report both: present the primary correlation (High + Moderate combined), and present moderate-tier separately with the caveat that ground truth support is weaker. This is the default.

---

### Q2: Language Priority

**QUESTION:** Both Telugu and Hindi are MUST HAVE but timeline may not support both. Which ships in the demo build?

**OWNER:** Project Lead
**DEADLINE:** Day 3 (before Phase 2 planning)
**DEFAULT:** Telugu ships first, Hindi in cut list
**RISK IF DEFAULT IS WRONG:** The demo audience may not include Telugu speakers — Hindi may have been higher value for the pitch. However, Telugu is the language of Andhra Pradesh and Telangana, where the volunteer study is conducted, so it is the higher priority for the study itself.

**DISCUSSION:** The volunteer study is conducted in a Telugu-speaking region. Telugu must be complete for the study to be valid. If timeline allows, Hindi is added. If not, Hindi is deferred to a post-study update. This is the default.

---

### Q3: Manual Override for Quality Gate

**QUESTION:** Does a hard gate with no override protect data integrity at the cost of field usability? Decision: allow override with warning and flag, or hard gate with no override?

**OWNER:** Flutter Dev 1 + UI/UX Designer
**DEADLINE:** Day 5 (before quality gate implementation)
**DEFAULT:** Allow override with warning and flag (FR-QG.006)
**RISK IF DEFAULT IS WRONG:** Flagged results in validation data reduce clean sample size below n=20. If too many workers use the override, the clean dataset may be too small for statistical analysis. The warning must be sufficiently prominent to discourage casual use.

**DISCUSSION:** A hard gate may be the right choice for the volunteer study to ensure clean data. However, field usability is also important — an ASHA worker who cannot get a clean capture may abandon the tool. The override with warning and flag provides data integrity (the flag allows filtering) while preserving usability. The study protocol should instruct workers to retry before overriding. This is the default.

---

### Q4: Sync Conflict Resolution

**QUESTION:** If a record exists on both local and server with different values, which wins?

**OWNER:** Backend Developer
**DEADLINE:** Day 6 (before sync implementation)
**DEFAULT:** Local wins (FR-SY.004)
**RISK IF DEFAULT IS WRONG:** Server could overwrite a result that was corrected locally after an initial sync. For this use case, the local device is the source of truth — the data is generated on-device and the worker does not modify records after generation. Server-side corrections are not expected during the study. Local wins is the appropriate rule.

**DISCUSSION:** For the volunteer study, local-wins is correct. For a future production deployment, a more sophisticated conflict resolution strategy (e.g., timestamp-based) may be needed. For v1, local-wins is the default.

---

### Q5: 30-Day Deletion Trigger

**QUESTION:** Does the deletion clock start from capture date or study end date? Per-capture calendar date vs. fixed study end date.

**OWNER:** Project Lead (ethics decision, not technical)
**DEADLINE:** Day 2 — this affects consent form language, which must be finalized in Phase 1
**DEFAULT:** Per-capture calendar date (FR-LS.005)
**RISK IF DEFAULT IS WRONG:** Consent form states one thing, app does another — ethics violation, not just a bug. If the consent form says "data deleted 30 days from capture" and the app deletes 30 days from study end date, the team has violated the consent agreement.

**DISCUSSION:** Per-capture deletion is the most privacy-preserving approach and is consistent with the principle of data minimization. It also makes the deletion logic simpler — each record has its own deletion date based on its capture date. Study end date is not relevant. The consent form must clearly state that deletion is per-capture. This is the default.

---

### Q6: Backend Database — PostgreSQL or SQLite?

**QUESTION:** For the volunteer study, should the backend use PostgreSQL or SQLite?

**OWNER:** Backend Developer + Project Lead
**DEADLINE:** Day 3 (before backend implementation)
**DEFAULT:** PostgreSQL (FR-SY.001)
**RISK IF DEFAULT IS WRONG:** PostgreSQL requires a hosting environment and increases deployment complexity. SQLite is simpler but may not be appropriate for a production-like sync API.

**DISCUSSION:** For the volunteer study, the dataset is small (n=20, < 100 records). SQLite is sufficient for the study and reduces deployment complexity. However, PostgreSQL is the standard for FastAPI and would be required for a production deployment. The study team should decide based on their deployment capabilities. If the backend can be deployed easily with PostgreSQL (e.g., on Render or Railway), use PostgreSQL. If deployment is a concern, use SQLite for the study. The default is PostgreSQL because it demonstrates production-readiness.

---

### Q7: Telugu PDF Font Embedding Validation

**QUESTION:** The `pdf` package may not render Telugu script correctly even with custom font embedding. What is the fallback?

**OWNER:** Flutter Dev 1 + Project Lead
**DEADLINE:** Day 1 (proof-of-concept)
**DEFAULT:** If `pdf` package fails, use plain text report (TXT) instead of PDF
**RISK IF DEFAULT IS WRONG:** A plain text report is less professional and cannot be visually formatted with the disclaimer in a distinct section. However, it still conveys the screening results and is shareable.

**DISCUSSION:** Telugu PDF rendering is a known risk. The team tests this on Day 1. If the `pdf` package works, the risk is resolved. If it fails, the team escalates immediately and either: (1) switches to a different PDF library (limited time), or (2) generates a plain text report with the same content. The plain text report is the fallback. This is the default.

---

## 13. REFERENCES AND DEPENDENCIES

### Research

**[1] Tamir, A., et al. (2017).** "Detection of anemia from image of the anterior conjunctiva of the eye by image processing and thresholding." *IEEE Region 10 Symposium (TENSYMP)*.
- **Role:** Source of CIELAB a* threshold values for anemia classification (a* < 5 for High Risk, 5 ≤ a* < 10 for Moderate Risk, a* ≥ 10 for Low Risk).
- **Caveat:** The thresholds were developed for a laboratory setting with controlled lighting and a spectrophotometer. The study team is using these thresholds as a reference point, not as validated clinical cutoffs for the smartphone implementation. The volunteer study will measure the correlation between the smartphone-derived a* values and ground truth, not the absolute accuracy of the thresholds.

**[2] Skinopathy AI. (2026).** "Smartphone-Based Ophthalmic Screening and Longitudinal Tracking Using Lightweight Computer Vision." *arXiv:2603.00161*.
- **Role:** Contemporaneous prototype using similar LAB-based methodology for ophthalmic screening.
- **Caveat:** Non-peer-reviewed preprint. Cited for methodological context only. Do not cite as validation evidence for the AnamoAI tool.

**[3] NFHS-5 (2019–21).** National Family Health Survey, India. Provides prevalence data for anemia in pregnant women (57% of women aged 15–49 are anemic).

**[4] NHM Annual Report (2022–23).** National Health Mission, India. Provides data on the number of ASHA workers (approximately 1.04 million nationally).

### Regulatory

- **Information Technology Act 2000 (India)** — governs digital data and privacy.
- **Information Technology (Amendment) Act 2008** — provides the legal framework for data protection in India.
- **Sensitive personal data:** Health data is considered sensitive personal data under the IT Act and must be handled with appropriate consent and security measures.
- **Consent requirements:** The app obtains explicit consent before any data is collected (FR-CS.002). Consent is recorded with timestamp (FR-CS.003).
- **Data retention and deletion:** The app automatically deletes data after 30 days (FR-LS.005), consistent with the principle of data minimization.
- **ICMR ethical guidelines:** The volunteer study (n=20) is an observational feasibility study. The Project Lead must confirm with the faculty supervisor whether institutional ethics clearance is required. The consent form must be reviewed and approved by the faculty supervisor before the volunteer study begins.

### Technical Dependencies

| Dependency | Version / Constraint | Risk | Mitigation |
|------------|---------------------|------|------------|
| Flutter | 3.x | Flutter updates may break packages | Pin Flutter version in CI; test on stable channel |
| google_mlkit_face_mesh_detection | Latest stable (pinned) | Google deprecates ML Kit APIs | Pin version; Phase 1 test validates compatibility |
| sqflite | Latest stable | Compatibility with Android 8.0 | Test on Android 8.0 emulator in Phase 1 |
| sqflite_sqlcipher | Latest stable | AES-256 encryption may fail on some devices | Test encryption on reference device in Phase 1 |
| FastAPI | 0.100+ | Deployment environment constraints | Can run locally or on cloud free tier; API can be mocked |
| PostgreSQL | 15+ | Hosting environment constraints | Can use SQLite as fallback for the study |
| pdf package (pub.dev) | 3.10.4+ | Telugu font rendering | Phase 1 proof-of-concept validates Telugu rendering; fallback to plain text if needed |
| Flutter camera plugin | Latest stable | Camera preview latency on low-end devices | Phase 1 testing on reference device; reduce overlay complexity if needed |
