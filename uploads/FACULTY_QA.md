# Faculty / internal-jury questions — 20 answers

Memorize the short answer. The long line is only if they push.

---

**1. Is this a medical device?**  
No. It is a non-diagnostic triage aid. Every result screen carries a disclaimer. A PHC doctor still does the blood test.

**2. Can it tell hemoglobin?**  
No. It never displays Hb or bilirubin. Only Low / Moderate / High / Unable to assess.

**3. What is the accuracy?**  
We will not claim a clinical accuracy number. Thresholds are prototype heuristics. A 20-person feasibility check is optional after nomination, not a trial.

**4. Didn’t Tamir already do this in 2017?**  
Tamir used RGB red-vs-green on 19 people. We cite that as prior art. Our bins are not theirs. Our product is the ASHA workflow: Telugu, offline, consent, referral PDF.

**5. Why Flutter, not native Android?**  
One codebase, fast iteration, custom fonts for Telugu in UI and PDF. Face Mesh is Android-only; we are not shipping iOS.

**6. Why not a deep-learning model?**  
A 14-day team cannot train and convert a reliable on-device segmenter. Deterministic colour maths we can defend. RITnet is v2.

**7. Will it work on a cheap phone?**  
Target is Android 8, ~8 MP rear camera, Snapdragon 665 class. If the live overlay drops below 15 FPS we fall back to a static guide.

**8. Different phones show different colours.**  
Yes. White-paper calibration corrects the room light, not the sensor. We log device model. Device profiles are v2. We will say this to SIH judges.

**9. Newborn jaundice is the real emergency. Why cut neonates?**  
Face Mesh fails on newborn faces. Shipping a kernicterus story with a camera that cannot lock a face is unsafe. v1 is maternal / household. Neonates are v2.

**10. How do you photograph the inner eyelid?**  
The worker asks the person to look up and gently pulls the lower lid. Face Mesh often drops. The ellipse guide still works. That is designed, not a bug.

**11. What if the photo is blurry?**  
The shutter stays closed until blur, light, and (for the open eye) eye-open checks pass. After three failed tries that part is “unable to assess,” not “low risk.”

**12. Internet in villages is poor.**  
Core flow is airplane-mode complete, including the PDF. Sync is optional and silent.

**13. Privacy of a woman’s eye photo?**  
The JPEG never hits disk. No name, no GPS in the database. A name typed for the PDF is written on the PDF only, then dropped.

**14. ABDM / ABHA?**  
Out of v1. We will mention it as a roadmap item if asked, not as a feature we have.

**15. How is this different from a wellness camera app?**  
Primary user is an ASHA, not a consumer. Output is a referral action in Telugu, not a score. Regulatory posture is written as product rules, not a footer.

**16. Can six students build this?**  
Yes, because we cut. No extra hardware, no trained net, no Hindi in v1, no admin dashboard, sync can be mocked for demo.

**17. What do you show on internal demo day if you have no app yet?**  
This PPT. If they demand a prototype after nomination, we have a 10-day build spec already written.

**18. Who is the faculty mentor and what do they sign?**  
They confirm the team and, before any volunteer study, the consent form and the eight “next action” lines. Not a clinical endorsement of accuracy.

**19. Why should we nominate you instead of 20 other teams?**  
Narrow problem, honest limits, rural constraint (offline + cheap phone), and a spec that is already implementation-ready.

**20. Team name / composition issues?**  
Team name is VYTRA — no college in the name. Six members, at least one woman. All MRCET. One leader.

---

If you do not know: “We don’t have that number yet; we will not invent one.” Then stop talking.
