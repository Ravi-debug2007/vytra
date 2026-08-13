# VYTRA — What This Idea Is

**Read this first.** It is the whole project in one sitting: the problem, the product, how it works, what it will not do, and what the team has already prepared.

| | |
|---|---|
| **Name** | VYTRA |
| **Line** | See Health. Detect Early. |
| **Expansion** (pitch only) | Vision + Vitality + Tracking + AI |
| **What it is** | An offline Android screening *aid* for ASHA workers |
| **What it is not** | A medical device, a diagnosis, or a blood-test replacement |
| **Conditions** | Anemia risk and jaundice risk |
| **Hackathon** | Smart India Hackathon 2026 · MRCET |
| **Team name** | VYTRA (must not contain the college name) |

---

## 1. The idea in eight lines

In a village or slum household, an ASHA worker has a phone, a register, and very little time. She does not have a lab. She cannot draw blood. Moderate anemia in a pregnant woman, or yellowing in the eye, often goes unrecorded until someone walks to a Primary Health Centre — if they walk at all.

VYTRA uses the phone she already carries. She photographs two things:

1. the **inner pink of the lower eyelid** (after gently pulling the lid down) — for **anemia risk**
2. the **outer white of the open eye** — for **jaundice risk**

The app, **on the phone, with no internet**, turns those colours into a simple class: **Low / Moderate / High / Unable to assess**. It then makes a one-page **referral PDF** she can send on WhatsApp or print. It never prints a hemoglobin number. It never says “you have anemia.” A doctor at the PHC still does the real test.

That is the whole product.

---

## 2. Why the name is VYTRA

**Official logo:** a forest-green **V** with a lime **leaf-pulse** (heartbeat + leaf) through it, a lime dot, and the wordmark **vytra** in lowercase. Under it: **AI HEALTH SCREENING**.

Use the PNG. Do not redraw it. The small designer note “vitality + diagnostics” is **not** part of the logo and must never appear in the app or on a result — VYTRA does not diagnose.

| Letter | Stands for | Meaning in this project |
|---|---|---|
| **V** | Vision | The camera is the sensor. We look at the eye, not at a blood vial. |
| **Y** | Your health | Built for the person in the house, used by the worker in front of them. |
| **T** | Tracking | Each visit becomes a dated, shareable note — not only a verbal hunch. |
| **R** | Recognition / Response | Recognise a colour signal; respond with a referral action, not a prescription. |
| **A** | AI / Analysis | On-device colour analysis. Not a cloud “AI doctor.” |

**Tagline:** *See Health. Detect Early.*

The tagline is for the home screen and the pitch. It must **not** appear on the result screen or the PDF. Those surfaces carry a medical disclaimer, not a slogan. “Detect Early” next to a red “High risk” tile would sound like a diagnosis.

The backronym (Vision + Vitality + Tracking + AI) is for the **college / SIH deck only**. Do not print it inside the worker app. It reads as a clinical claim.

The old working title **AnamoAI** is retired. Do not use it on slides, the app, or the PDF.

---

## 3. The problem, said plainly

India already knows how to diagnose anemia and jaundice **in a facility**. The gap is earlier, at the **household visit**.

- There is often **no lab**, no hemoglobinometer, and no reliable 4G.
- The ASHA is not a clinician. She needs a **binary-ish decision**: refer today, watch, or continue routine care.
- Subjective “you look pale” does not travel. The PHC doctor cannot use it.
- **Anemia in pregnancy** is extremely common (NFHS-5: a majority of women 15–49 are anemic). Missed moderate-to-severe anemia raises the risk of low birth weight, preterm birth, and hemorrhage.
- **Jaundice** that is visible in the eye white is a reason to get a clinical check. (Newborns are the most urgent clinical story — and we are **not** claiming to solve that in version 1. See §8.)

Every alternative fails at least one field constraint:

| Alternative | Why it fails here |
|---|---|
| Send everyone to the PHC for a blood test | Families do not always go. The PHC cannot absorb universal testing. |
| Give every ASHA a hemoglobinometer | Cost, calibration, consumables, training, theft, maintenance. |
| Pulse oximeter | Measures oxygen, not hemoglobin. It stays normal until anemia is already severe. |
| Cloud AI that scores an uploaded photo | Needs internet. Uploads a biometric image. Per-query cost. Privacy risk. |
| Extra clip-on lens | Another object to lose. Not “zero per-test cost.” |

A smartphone camera is the only sensor that is already in the bag, costs nothing per click, and can run **offline**.

---

## 4. Who it is for

| Person | Do they open the app? | What they need |
|---|---|---|
| **ASHA worker** | Yes — primary user | Finish in under five minutes. Icons first. Telugu or English. A clear next action. A PDF to leave behind. |
| **Patient / family** | No | Consent. They do not operate the phone. |
| **PHC medical officer** | No | They read the PDF. They are supposed to be skeptical. The disclaimer is for them as much as for us. |
| **College / SIH jury** | They see the deck and later a demo | A real Indian problem, a buildable plan, honest limits. |
| **Study team** (later) | Hidden research view, PIN | Raw colour numbers for analysis. Never shown to the ASHA. |

Literacy assumption: the worker may not be comfortable in English. The core flow must work in **Telugu**. Hindi is a later add-on if time remains.

Device assumption: a **mid-range or NHM-issued Android**, Android 8 and up, about 8 MP rear camera. Not a flagship. Distribution for the study / demo is a **sideloaded APK**, not Play Store.

---

## 5. What a visit looks like

This is the story you should be able to tell in one minute.

1. The ASHA opens VYTRA. It works with **airplane mode on**.
2. She picks **Telugu** or English (once).
3. **Consent** — the person (or guardian) agrees. If they refuse, nothing is stored and the camera never opens.
4. She taps a **skin-tone category** and the **kind of light** in the room (window, bulb, shade, sun). That is for later analysis, not for the worker to interpret.
5. She photographs a **plain white paper**. That is how the app corrects the colour of the room light. No skip. A yellow wall or a brown desk is rejected with a plain instruction.
6. **Anemia photos.** She asks the person to look up and gently pulls the lower lid down so the **inner pink tissue** shows. She fills a ring on the screen with that pink. Up to three tries. She needs two usable shots.
7. **Jaundice photos.** She asks the person to look toward their nose so the **outer white** of the eye is large. She does **not** pull the lid. Up to three tries. Two usable shots.
8. In a few seconds the phone shows two tiles: anemia and jaundice, each **Low / Moderate / High / Could not read**, with a next action in ordinary language (“Refer to the PHC for a blood test today”).
9. If either result is High, a banner says: accompany them to the PHC **today**.
10. The full disclaimer is on that screen, in the same language, not hidden behind “read more.”
11. She may type a **name only for the PDF**. That name is written on the PDF and then forgotten. It is never saved in the app.
12. She shares the PDF on WhatsApp. The visit is done.

If she cannot get two clean photos of one part, that part is **Could not read** — not silently marked Low. The other part can still succeed.

---

## 6. What the app measures (and the honest version of “AI”)

The eye tissues we care about change colour when blood is low or when bilirubin is high:

- A healthy inner eyelid is **pink** (more red). A pale inner eyelid is a classical clinical *sign* of anemia — not a number, a sign.
- A healthy eye-white is **off-white**. A yellow eye-white is a classical *sign* of jaundice.

Phones do not see “pink” the way a lab does. So VYTRA:

1. Corrects the photo using the white paper (so a yellow bulb does not make everyone look jaundiced).
2. Converts the average colour of the chosen pixels into **CIELAB**, a standard colour space.
3. Looks at **a\*** (red–green) on the lid for anemia, and **b\*** (yellow–blue) on the sclera for jaundice.
4. Puts that number into three prototype buckets: Low / Moderate / High.

That is the “AI.” It is **deterministic colour maths on the phone**, not a neural network that predicts hemoglobin, and not a cloud model.

The buckets are **prototype heuristics** so the app can return a class. They are **not** clinical cutoffs and they are **not** copied from Tamir 2017. Tamir’s paper used simple red-versus-green RGB rules on 19 people. We mention that paper as *prior art* (“people have photographed the eyelid before”). We must **never** tell a jury “Tamir proved our thresholds.”

If the photo is bad, the honest output is **Unable to assess**.

---

## 7. How the technology is put together

You do not need this to explain the idea. You need it so nobody on the team invents a different stack in the pitch.

| Layer | Choice | Why |
|---|---|---|
| App | Flutter, **Android only** | One codebase, fast to iterate, Telugu fonts in UI and PDF. |
| Aiming the camera | Google ML Kit Face Mesh (468 points) | Helps find the open eye. **Android-only, still Beta.** |
| Inner eyelid | Drawn guide ring + worker pulling the lid | Face Mesh often **fails** when the lid is pulled. That is expected. The ring still works. |
| Colour | True CIELAB on the phone | No internet. No per-test API bill. Auditable. |
| Storage | Encrypted SQLite on the phone | Works offline. No name, no photo, no GPS. |
| Report | PDF generated on the phone | Share via WhatsApp / Files. |
| Optional later | Small FastAPI server | Syncs anonymous risk classes when the phone next has internet. The demo does not depend on it. |

**Quality checks before a photo counts**

- Not too blurry
- Not too dark or too bright
- For the open-eye shot: the eye is actually open

The capture button stays dead until those pass. After three failed tries on one part → Unable to assess.

**Secondary tools (optional, not the product):** under **More tools**, a skin check (Hugging Face image model) and a teeth check (Roboflow boxes + on-phone geometry). They need internet. The photo is sent to that company, then deleted here. Separate consent. They must not be pitched as “VYTRA diagnoses melanoma” or “VYTRA grades your smile like an orthodontist.” First features we cut if time is short. Full rules: `vytra-vibespec/11_SECONDARY_MODULES.md`.

---

## 8. What version 1 will not do

Saying no is part of the idea. Faculty and SIH judges reward a small product that can actually be built.

| Out of v1 | Why |
|---|---|
| **Newborn / neonatal jaundice** | Face Mesh is trained on adult/child faces. Newborns fail detection. Shipping a kernicterus story with a camera that cannot lock a face is unsafe. This is v2. |
| Hemoglobin or bilirubin numbers | We do not have a validated conversion. Showing a fake g/dL is worse than showing a risk class. |
| “Clinically validated / 95% accurate / ICMR approved” | We have not run a diagnostic trial. A 15–20 person feasibility check, if we do it, proves the *pipeline*, not clinical accuracy. |
| Hindi UI | Telugu + English first. Hindi is the first language we cut if the clock slips. |
| Extra hardware, clip-on lenses, colour cards | Breaks zero per-test cost. |
| Treating skin or teeth demos as the main product | They exist as **optional internet tools** (Hugging Face / Roboflow). They send a photo off-device. They are not diagnoses. They are the first feature we cut. |
| ABDM / ABHA national health ID | Compliance and time. Roadmap only. |
| iOS | Face Mesh plugin does not ship on iOS. |
| Play Store listing | Study / demo APK is sideloaded. |

If a teammate adds any of the above to the PPT, take it out.

---

## 9. Safety, consent, and privacy

These are product rules, not fine print.

**On every result screen and every PDF, in the active language:**

> This screening result is not a medical diagnosis. It is a triage aid for trained health workers only. All results require confirmation by a qualified medical professional. Do not make treatment decisions based on this result alone.

Never claim: accuracy, approval, “no further test needed,” or a lab number.

**Consent is two things**

1. A **paper form** the volunteer (or guardian) signs on a study day.
2. An **in-app Agree** before the camera opens. Decline → nothing stored, camera stays off.

**What is stored on the phone**

- Risk class, time, phone model, skin-tone category, lighting, technical quality numbers, anonymous IDs.

**What is never stored**

- Name (except optionally on the PDF, then discarded)
- Photograph of the eye or the paper
- GPS
- ASHA’s personal identity

Records become **eligible for deletion after 30 days** and are removed the next time the app cleans up. Uninstalling the app deletes the local copy. If a copy was synced to a study server, that copy follows the server’s own schedule — this must be said on the consent form.

---

## 10. Why this is a good SIH / college idea

Juries compare you with teams that promised an “AI hospital in an app.” VYTRA wins if it sounds **buildable and honest**.

| Jury question | Our answer |
|---|---|
| Is the problem real and Indian? | Yes. ASHA visit, no lab, NFHS anemia burden. |
| Can six students build it in a hackathon? | Yes. No extra hardware, no trained neural net, spec already written. |
| Does it respect the field? | Offline-first. Cheap phone. Telugu. Zero rupees per test. |
| Are you overselling medicine? | No. Disclaimer, Unable-to-assess, neonates out, no Hb number. |
| What is new if papers already photographed the eye? | The *system*: ASHA workflow, lid protocol, Telugu, privacy, referral PDF — not a new magic threshold. |

**Words that fail a jury — do not use them**

- diagnose / clinically validated / 95% accurate / FDA / ICMR approved
- “works on newborns” (v1)
- “Tamir proved our cutoffs”
- Team name with MRCET in it

---

## 11. What the team has already produced

You are not starting from a blank page.

| Folder | What it is | When to open it |
|---|---|---|
| `vytra-college-submission/` | 3-day plan, 6-slide PPT, 3-min script, faculty Q&A, roster, submit checklist | **Now** — until the college approves you |
| `VYTRA_THE_IDEA.md` (this file) | One briefing for any teammate or mentor | Anytime someone is lost |
| `vytra-vibespec/` | Full implementation spec: screens, design, colour maths, schema, Telugu strings, consent forms | **Only after** nomination, when you start building |

The spec pack is written so a coding assistant can build from it without inventing medical copy. It is **not** what you submit to the college.

---

## 12. What happens next (in order)

1. **Next 3 days** — college PPT gate. Six slides. Six names (at least one woman). Faculty mentor. Official problem-statement ID on slide 1. Submit the PDF. Do **not** start coding.
2. **If nominated** — 10-day build from `vytra-vibespec/`. First slice: language → home → consent, plus a colour-maths unit test. Then camera. Sync last.
3. **Internal / SIH demo** — airplane mode on, Telugu path, two photos, disclaimer, PDF. If Face Mesh dies on stage, the drawn ring still works. That is a designed fallback.
4. **Optional volunteer check** — about 20 people, paper consent, no clinical-accuracy claim. Pulse oximetry is a weak proxy for moderate anemia; say so if asked.

---

## 13. The one-sentence versions (memorize)

**For a faculty member in a corridor**

> Offline phone app for ASHA workers. Inner eyelid and eye-white photos. Risk class and a referral PDF. Not a diagnosis. No extra hardware.

**For the official idea box**

> VYTRA is an offline-first Android screening aid that lets an ASHA worker photograph the everted lower eyelid and the temporal sclera, receive anemia and jaundice risk classes (low / moderate / high / unable to assess), and share a referral PDF — with no internet, no consumables, and no claim of medical diagnosis.

**For a teammate who just joined**

> We are not building a doctor. We are building the missing note at the household visit.

---

*Pack aligned to VYTRA specification 1.3.0 · 2026-08-12 · Not a medical device.*
