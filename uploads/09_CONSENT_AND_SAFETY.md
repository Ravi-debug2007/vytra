# 09 — Consent and Safety

Two consent artefacts exist. Do not collapse them.

| Artefact | Who signs | Where |
|---|---|---|
| **Paper study consent** | Volunteer (or guardian) + worker + study team | `legal/consent_form_en.md`, `legal/consent_form_te.md`. Printed. Not in the app. |
| **In-app consent** | ASHA taps Agree on behalf of the visit | Locked strings `consentBody`. Required before the camera. |

The in-app screen is a **gate**, not a substitute for the signed paper form on study days.

---

## 1. Roles

| Role | Consent they give |
|---|---|
| Volunteer / patient | Paper form. Purpose, photos discarded, 30-day eligibility, right to refuse, study-server copy. |
| ASHA / operator | In-app Agree. Confirms the person in front of them has agreed to this visit’s photographs. |
| Guardian | Paper form if the volunteer is a minor. v1 does **not** screen neonates; minors still need a guardian if recruited. |

The app never records *whose* finger tapped Agree. That is why the paper form exists.

---

## 2. In-app rules (implementation)

- S03 is unavoidable on every new screening.
- Decline: no row, no camera, no decline log.
- Agree: write `consent_recorded_at` **before** pushing S04.
- Camera permission is requested on S05, after consent.
- Copy is LOCKED in `07_LOCALIZATION.md`. Do not shorten it to fit a card.

---

## 3. Paper form rules (study logistics)

- Use the Telugu form when the volunteer prefers Telugu.
- One form per volunteer, not per photograph.
- Store signed paper with the faculty supervisor. Do not photograph the signed form into the app.
- Faculty supervisor must approve the form **before** Day 4 (Phase 1 go/no-go).
- Confirm with the supervisor whether institutional ethics clearance is required. This pack does not grant it.

---

## 4. Safety copy lock

| Surface | Must show |
|---|---|
| S01 footer | `languageFooter` |
| S08 | `disclaimerFull`, 12 sp, above the fold, both languages |
| PDF body | `disclaimerFull` in a bordered box, ≥ 11 pt |
| PDF footer | `pdfFooter` |

Automated test: pump S08 in `te` and `en` and assert `disclaimerFull` is in the tree and has `fontSize >= 12`.

---

## 5. Forbidden product behaviour

Treat each as a **critical defect**:

1. Displaying a\*, b\*, L\*, Hb, or bilirubin on S08 or the PDF.
2. Saving a JPEG of the eye or the white reference.
3. Writing the PDF name field into SQLite or the sync payload.
4. Claiming accuracy, approval, or “no further test needed.”
5. Classifying `< 2` valid captures as `LOW`.
6. Letting S06 open without a valid white reference in this process.
7. Shipping `DEBUG_LAB=true` on the study APK.

---

## 6. Data-subject rights (study)

A volunteer who wants their study-server copy deleted before the server schedule asks the project lead. The lead uses `POST /api/v1/devices/revoke` only if the whole device must die; individual row deletion on the server is a manual SQL delete by `screening_id` (known to the study team from the session log, not from the volunteer). Because rows are anonymous, the team can honour a deletion request only if they know which session IDs belong to that visit. **Log session IDs on paper next to the consent form on study day.** Do not put the name in the database to make this easier.

---

## 7. Incident rule

If a photograph or a name is discovered on disk, treat it as a privacy incident: delete the file, rotate the study token / org code if a named PDF leaked into logs, and tell the faculty supervisor the same day.
