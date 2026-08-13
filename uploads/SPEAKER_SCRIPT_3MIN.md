# VYTRA — 3-minute college pitch

**Speaker:** Team lead. **Timer:** 2:50–3:10. **Slides:** advance on the bold cues.

Do not improvise medical claims. If you blank, read the idea sentence and sit down.

---

**[Slide 1 — 15 s]**

Good morning. We are team **VYTRA** from MRCET.

VYTRA is an **offline smartphone screening aid** for ASHA workers. It does **not** diagnose. It helps a trained worker decide whether to **refer today**.

---

**[Slide 2 — 40 s]**

In a village home there is no hemoglobinometer and no bilirubin lab. The ASHA has a phone, twenty minutes, and a paper register. Moderate anemia in pregnancy and visible jaundice still get missed until the family walks to a PHC — if they walk at all.

VYTRA uses that phone. The worker photographs the **inner lower eyelid** for anemia and the **white of the eye** for jaundice. The app returns **low / moderate / high / unable to assess**, plus a one-page referral PDF.

It never prints a hemoglobin number. It never says “you have anemia.”

What is new is not “AI on an eye.” It is a field workflow: Telugu, no internet, no extra hardware, and an honest **unable to assess** when the photo is bad.

---

**[Slide 3 — 50 s]**

Stack is boring on purpose. **Flutter** on Android 8 and up. **Google ML Kit Face Mesh** only to aim at the open eye. Colour is **CIELAB on the phone** — no cloud model, no per-test API cost.

Eight steps: language, consent, lighting note, white paper for calibration, two or three lid photos, two or three sclera photos, risk class, PDF.

If the worker cannot get two clean photos, the app writes **unable to assess**. It does not invent a “low risk.”

---

**[Slide 4 — 40 s]**

This is buildable in a hackathon. Six people. No custom lens. No training a neural net.

We already know the hard parts: phone cameras disagree on colour; pulling the eyelid breaks face-mesh; **newborns are out of version 1** because the mesh is an adult-face model. We will say that to SIH judges too.

Mitigation: white-paper calibration, a static guide if mesh fails, and a 14-day plan that cuts Hindi, dashboards, and cloud sync if time slips.

---

**[Slide 5 — 25 s]**

NFHS-5: more than half of Indian women 15–49 are anemic. There are about a million ASHAs. A tool that costs **nothing per test** and works in airplane mode is the only kind that survives a household visit.

Privacy: the photo is discarded. No name in the database. Records become eligible for deletion after 30 days.

---

**[Slide 6 — 20 s]**

Prior papers photographed the conjunctiva with RGB thresholds on tiny samples. We cite them as prior art, not as our accuracy.

We are asking the college to nominate team VYTRA. We will build the offline Android aid — not a medical device.

Happy to take questions.

---

## If they stop you early

Say only this:

> Offline phone app for ASHA workers. Inner eyelid and eye-white photos. Risk class and a referral PDF. Not a diagnosis. Six people, no extra hardware. Please nominate us.
