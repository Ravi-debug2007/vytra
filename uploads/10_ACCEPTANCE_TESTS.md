# 10 — Acceptance Tests and Fixtures

A build is **done** when every item in §1 is green on the reference device (Snapdragon 665 class, Android 10+) **and** on an API 26 emulator. Items in §2 are study-day gates, not code gates.

---

## 1. Product acceptance

### 1.1 Automated (CI or `flutter test`)

| ID | Test | Pass |
|---|---|---|
| T-LAB-01 | Port of `cielab_reference.py` vs `golden_cielab.json` | max \|Δ\| ≤ 0.05 on L*, a*, b* |
| T-CLS-01 | Boundary table in `golden_cielab.json` → `classify_*` | exact enum match |
| T-AGG-01 | 0 or 1 valid value → `UNABLE_TO_ASSESS`, signal null | exact |
| T-AGG-02 | Two valid values → mean as median | exact |
| T-DIS-01 | S08 pumped at 360×640, `te` and `en`, every risk pair including dual HIGH | `disclaimerFull` visible, `fontSize >= 12`, no overflow exception |
| T-SCH-01 | Insert screening + 4 captures in one transaction; crash simulated after first statement does not leave orphans | 0 or all |
| T-PAY-01 | Sync encoder refuses a map that contains `patient_name` or `patient_ref` | compile-time / unit fail |
| T-L10N-01 | Every key in `app_en.arb` exists in `app_te.arb` | exact |

### 1.2 Manual, airplane mode

| ID | Steps | Pass |
|---|---|---|
| M-OFF-01 | Airplane mode. S01→S09. Share PDF to Files. | No internet error anywhere. PDF opens. |
| M-OFF-02 | Toggle airplane off after save. S10. | Status becomes Sent if a server is configured; otherwise stays Waiting without an error dialog. |
| M-WR-01 | Photograph a brown desk as white reference. | Cast failure copy. No skip button. |
| M-WR-02 | Photograph matte A4 under a window. | Gains accepted, S06 opens. |
| M-AN-01 | Anemia series: cover the lens twice, then two sharp everted-lid shots. | After 2 valid, “Use these” appears. |
| M-AN-02 | Three blurry anemia shots. | Anemia = Could not read. Jaundice series still offered. |
| M-JA-01 | Blink through jaundice. | Eye lamp red, shutter dead. |
| M-JA-02 | No face in frame for 15 s. | Ellipse-only fallback appears. Capture tagged `mesh_used = 0`. |
| M-PDF-01 | Enter a name, generate, share. Open DB with the key. | Name is not in any table. |
| M-PDF-02 | Telugu locale PDF. | `తెలుగు` glyphs, not tofu. Disclaimer present. |
| M-SAFE-01 | Read S08 aloud in both languages. | Matches `disclaimerFull` character for character. |
| M-PERM-01 | Deny camera. | S05 coaching, no crash, no gallery prompt. |
| M-KILL-01 | Force-stop mid S06. Relaunch. | Home. No half row. |

### 1.3 Device and security

| ID | Steps | Pass |
|---|---|---|
| D-ENC-01 | `adb shell` + `sqlite3` on `vytra.db` without the key | “file is encrypted or is not a database” |
| D-FPS-01 | Jaundice preview 30 s, `dumpsys gfxinfo` | p50 frame time < 50 ms |
| D-API-01 | API 26 emulator, full M-OFF-01 | pass |
| D-API-02 | API 34 physical, share sheet | pass |
| D-BAT-01 | One full session at 50 % brightness | < 2 % (soft) |

### 1.4 Sync (if backend is up)

| ID | Steps | Pass |
|---|---|---|
| S-REG-01 | Fresh install, online | Device row + token |
| S-SYN-01 | Save one screening, sync | Row on server, no name column |
| S-WIN-01 | Edit `anemia_risk` locally, sync | Server matches local |
| S-REV-01 | Admin revoke, sync again | 401, local data intact |

---

## 2. Study-day gates (humans)

- [ ] Faculty signed the paper consent form.
- [ ] Native Telugu speaker signed off S03, S08, PDF.
- [ ] Clinician initialled the eight action strings.
- [ ] `DEBUG_LAB=false` on the APK that volunteers touch.
- [ ] Session ID written on the paper form after each save.
- [ ] No claim of clinical accuracy in the pitch deck.

---

## 3. Fixtures

Do **not** commit identifiable eye photographs to a public repo.

### 3.1 Synthetic (in git)

`vision/golden_cielab.json` is the colour oracle. Enough for Lab and bins.

### 3.2 Team-only capture set (private drive)

On Day 2–3 the ML owner captures, on the reference device, under a window:

| File | Subject | Expect |
|---|---|---|
| `priv/white_a4.jpg` | Matte A4 | white-ref accept |
| `priv/white_wood.jpg` | Brown desk | cast reject |
| `priv/lid_ok_1.jpg` … `_3.jpg` | Team member, everted lid | ≥ 300 survivor pixels |
| `priv/lid_closed.jpg` | Lid not pulled | likely `ROI_TOO_SMALL` or low a* filter drop |
| `priv/sclera_ok_1.jpg` … `_3.jpg` | Temporal sclera | ≥ 200 survivors |
| `priv/sclera_blink.jpg` | Closed eye | EAR fail |

These files stay off git. A `test/vision_fixture_test.dart` may load them if `FIXTURE_DIR` is set, and must skip cleanly when it is not.

### 3.3 What a fixture test asserts

- White-ref accept/reject matches the table.
- Survivor counts meet minima on `*_ok_*`.
- No test asserts a medical class against a team-member photograph. Classes are tested only on synthetic RGB.

---

## 4. Demo script (SIH stage)

1. Airplane mode on. Say so out loud.
2. Telugu path, consent, metadata (IV, worker-assessed, indoor window).
3. White paper. Everted lid ×2. Temporal sclera ×2.
4. Results: point at shapes, then read the disclaimer.
5. PDF without a name. Share to Files. Open it.
6. Optional: turn network on, open S10, show Waiting → Sent.
7. If a judge asks for numbers: unlock research view, show a\*/b\*, then lock it. Never leave it open toward the audience.

If Face Mesh dies on stage, continue with the ellipse. That is a designed fallback, not an apology.

---

## 5. Definition of a failed release

Ship nothing that fails T-LAB-01, T-AGG-01, T-DIS-01, M-OFF-01, M-PDF-01, or D-ENC-01. Everything else can be ugly. Those six cannot be wrong.
