# VYTRA — 3-Day College Approval Plan

| | |
|---|---|
| **Goal** | Get the **idea PPT approved** by MRCET for the internal SIH hackathon / SPOC nomination |
| **Window** | **72 hours** |
| **What you submit** | 6-slide idea deck (PDF) + team form + faculty mentor confirmation |
| **What you do *not* build** | The app. Coding starts **after** the college says yes. |

This is a **presentation gate**, not an engineering sprint. A half-built APK will not get you nominated. A clean 6-slide idea in the official SIH shape will.

Official SIH idea decks are **maximum 6 slides including the title**. Points and diagrams only. No paragraphs. If the college or SPOC gives you the official `.pptx` template, **copy our content into that template** — do not invent a seventh slide.

---

## 0. Lock these 8 things in the first 90 minutes (Day 1, 09:00–10:30)

If any of these are still open at 10:30, **stop designing slides** and close them. A pretty deck with a missing problem statement or a 5-person team gets rejected.

| # | Lock | Owner | Done when |
|---|---|---|---|
| 1 | **Official problem statement** (PS ID + title + ministry) **or** “Student Innovation” if no PS fits | Lead | Written on Slide 1 |
| 2 | **Team name** = `VYTRA` (must **not** contain MRCET / college name) | Lead | Agreed in the group |
| 3 | **Exactly 6 members**, **at least one woman** | Lead | Names + gender + roll + phone + personal email in the roster |
| 4 | **Team leader** (one person, usually Ravikiran) | Lead | Named |
| 5 | **Faculty mentor** who has said “yes” in writing (WhatsApp is enough today) | Lead | Name + department + phone |
| 6 | **College SPOC** name and the **exact submit channel** (email / Google Form / SIH portal / print) | Lead | URL or email in the group |
| 7 | **Deadline** (date + time + timezone) | Lead | In the group pin |
| 8 | **One sentence idea** (do not rewrite after Day 1 noon) | All | See box below |

**Idea sentence (frozen):**

> VYTRA is an offline Android screening aid that lets an ASHA worker photograph the inner eyelid and the white of the eye, get anemia and jaundice **risk classes** (not a diagnosis), and share a referral PDF — with no internet and no per-test cost.

If the official PS is about something else (maternal health, rural diagnostics, ASHA digital tools), **map the same sentence onto that PS**. Do not invent a second product in 3 days.

---

## 1. Roles for these 3 days only

These are **PPT roles**. They are not the 14-day build roles.

| Role | Who (write the name) | Owns | Does **not** do |
|---|---|---|---|
| **R1 Lead** | Ravikiran Allampalli | PS lock, faculty, SPOC, roster, final PDF submit, 3-min talk | Pixel-pushing the slides |
| **R2 Problem & impact** | ________________ | Slides 2 and 5 words + NFHS / ASHA numbers | Architecture |
| **R3 Technical** | ________________ | Slide 3 stack + flow. One diagram. | Adding “AI/ML deep learning” fluff |
| **R4 Feasibility** | ________________ | Slide 4 risks + 14-day plan. Honest. | Hiding the neonate cut |
| **R5 Design & PDF** | ________________ | Visual consistency, icons, export PDF, template paste | Rewriting the science |
| **R6 Drill & checklist** | ________________ | 3-min script, Q&A, print/submit packet, backup drive | New features |

If someone is missing, R1 doubles as R6. Do not leave Design empty.

---

## 2. What “approved” means at college

Faculty / internal jury typically score:

| They look for | How VYTRA wins |
|---|---|
| Real problem, Indian context | ASHA visit, no lab, NFHS anemia burden |
| Buildable in a hackathon | Flutter + on-device colour maths. No custom hardware. No cloud model. |
| Honest scope | **Not** a medical device. Neonates out of v1. Prototype thresholds. |
| Team completeness | 6 people, 1 woman, mentor, unique team name |
| Clarity | 6 slides, no walls of text |

They punish: “AI diagnoses hemoglobin”, fake 99% accuracy, 20-slide decks, all-male team, college name inside the team name.

---

## 3. The 6 slides (do not add a 7th)

Use the file `VYTRA_SIH_Idea_Deck.pptx` in this folder. If SPOC sends the official SIH template, paste the **same headings and bullets** into it.

| # | Official SIH heading | One-line job |
|---|---|---|
| 1 | Title | Team, idea title, PS ID, category, college |
| 2 | Proposed solution | Problem → what VYTRA does → uniqueness |
| 3 | Technical approach | Stack + 8-step flow. No code. |
| 4 | Feasibility and viability | Why 6 people can build this; risks + mitigations |
| 5 | Impact and benefits | Who is helped; cost; privacy |
| 6 | Research and references | Prior work + what is **ours** + disclaimer |

---

## 4. Hour-by-hour

### DAY 1 — Lock and draft (no decoration)

| Time | Who | Task | Output |
|---|---|---|---|
| 09:00–10:30 | All, led by R1 | Close the 8 locks in §0. Open official SIH PS list. Pick **one**. | Pinned message: PS ID, team of 6, mentor, deadline |
| 10:30–11:00 | R1 | Message faculty mentor + SPOC: “We are submitting VYTRA, internal SIH, need your name on the form and a 15-min review on Day 3 morning.” | Two replies |
| 11:00–13:00 | R2, R3, R4 | Write slide 2 / 3 / 4 **in a shared doc**, bullets only, max 8 bullets/slide | Draft text |
| 13:00–14:00 | Break | — | — |
| 14:00–16:00 | R2 + R5 | Slide 5 + start placing text into the PPT | Draft deck v0.1 |
| 16:00–17:00 | R6 + R1 | 3-min script first pass. Time it. Cut anything that does not fit. | Script v0.1 |
| 17:00–18:00 | All (30 min stand-up) | Read all 6 slides out loud. Kill jargon. Freeze the idea sentence. | Deck v0.2 |
| Tonight (optional, 45 min) | R1 | Confirm PS wording matches the official statement (copy 1 line of the PS onto slide 1) | No surprises tomorrow |

**Day 1 exit:** every slide has words. Ugly is fine. Empty slides are not.

---

### DAY 2 — Make it juror-proof

| Time | Who | Task | Output |
|---|---|---|---|
| 09:00–10:00 | R5 | Visual pass: one typeface, one green, one flow diagram on slide 3, no clip-art eyes | Deck v0.8 |
| 10:00–11:00 | R4 + R3 | Feasibility: write the **three risks you will admit** (sensor variance, Face Mesh on everted lid, neonate out of scope). Faculty respect this. | Slide 4 final |
| 11:00–12:00 | R2 | Fact-check numbers. Only use: NFHS-5 anemia prevalence; “ASHA network exists”; “zero consumable cost”. Do **not** invent a % accuracy. | Slide 5 final |
| 12:00–13:00 | R6 | Research slide: Tamir 2017 = prior **RGB** work, n=19. We do **not** claim their cutoffs. Our claim = ASHA workflow + Telugu + offline + honest `UNABLE_TO_ASSESS`. | Slide 6 final |
| 14:00–15:30 | R1 + R6 | Two timed rehearsals. Phone recording. Kill “we diagnose”, “clinically validated”, “95% accurate”. | Script v1.0 |
| 15:30–16:30 | R5 | Export **PDF**. Check on a phone: all text readable, nothing cut off. Filename `VYTRA_SIH2026_Idea.pdf` | PDF v1.0 |
| 16:30–17:30 | All | Fill the college team form (names, gender, emails, phones, mentor). **Personal Gmail**, not only college IDs, if the SIH portal is next. | Roster.xlsx / form |
| 17:30–18:00 | R1 | Send PDF + script to faculty mentor: “Please comment by tomorrow 10:00.” | Email / WhatsApp |

**Day 2 exit:** PDF exists. Mentor has it. Script is 3:00 ± 15 seconds.

---

### DAY 3 — Approve, fix, submit

| Time | Who | Task | Output |
|---|---|---|---|
| 09:00–10:00 | R1 + mentor | 15-min faculty review. Take notes. Do not argue. | Comment list |
| 10:00–12:00 | R5 + owners of marked slides | Apply **only** mentor comments. No new features. | PDF v1.1 |
| 12:00–13:00 | R6 | Final 3-min run in front of 2 teammates. One person pretends to be a hostile faculty (“Is this a medical device?”). | Ready / not ready |
| 13:00–14:00 | R1 | Submission packet (see §6). Two people watch the upload. Screenshot the confirmation. | Submitted |
| 14:00–15:00 | R1 | Confirm SPOC received it. Ask when results / internal presentation slot is. | Calendar invite |
| After submit | All | Stop touching the deck. Sleep. Coding plan starts **only if** they ask for a prototype at the internal event — then open `vytra-vibespec/`. | — |

If the internal event includes a **live 3-minute pitch**, R1 speaks, R3 stands for one technical question, R2 for impact. Others do not interrupt.

---

## 5. Words that fail the college jury — banned

| Never say | Say instead |
|---|---|
| “We diagnose anemia / jaundice” | “We return a **risk class** for a trained worker” |
| “Clinically validated / 95% accurate / FDA / ICMR approved” | “Feasibility prototype; volunteer study if time” |
| “AI model predicts hemoglobin” | “On-device CIELAB colour heuristic” |
| “Works on newborn babies” | “v1 is maternal / household. Neonates are v2.” |
| “Tamir 2017 proved our thresholds” | “Tamir did RGB thresholding on 19 subjects; our bins are prototype heuristics” |
| Team name “MRCET_VYTRA” | `VYTRA` |

---

## 6. Submission packet (Day 3)

Put these in one Drive folder `VYTRA_SIH_College_Submit/`:

- [ ] `VYTRA_SIH2026_Idea.pdf` (6 slides)
- [ ] `VYTRA_SIH2026_Idea.pptx` (editable backup)
- [ ] Team roster: 6 names, gender, roll no., personal email, phone, department, year
- [ ] Faculty mentor name, designation, phone, email
- [ ] Problem statement ID + exact official title
- [ ] Leader college ID scan (if SPOC asks)
- [ ] Screenshot of the upload / sent email
- [ ] This plan, in case a faculty asks “what is your build plan after nomination?”

---

## 7. If the college also wants a 3-minute live pitch

Use `SPEAKER_SCRIPT_3MIN.md`. Structure:

1. 20 s — problem (ASHA, no lab)
2. 40 s — what VYTRA is / is not
3. 50 s — how it works (lid + sclera + offline)
4. 40 s — why it is buildable
5. 30 s — impact + ask (“nominate us”)

One backup speaker (R3) if R1 loses voice.

---

## 8. After approval (do not start this in the 3 days)

Only when the college / SPOC says you are nominated:

1. Open `vytra-vibespec/engineering/AGENT_PROMPT.md`
2. Scaffold the Flutter app
3. Run the 10-day build in `02_VIBE_SPEC.md` §11

Building during these 72 hours is how teams miss the PDF deadline.

---

## 9. Day-1 morning checklist (print this)

```
[ ] 6 names written, 1 woman confirmed
[ ] Team name is VYTRA (no college in the name)
[ ] Faculty mentor replied yes
[ ] SPOC name + submit link + deadline in the group
[ ] Official PS ID written on slide 1  OR  Student Innovation chosen on purpose
[ ] Idea sentence frozen (section 0)
[ ] R2 R3 R4 R5 R6 names filled in this document
```
