# VYTRA — Official brand lock

**Artwork source:** team logo, 2026-08-12.  
**Do not redraw the V, the pulse, or the wordmark in another font.**

| File | Use |
|---|---|
| `vytra_mark.png` | App icon, splash mark, slide corner, favicon |
| `vytra_logo_lockup.png` | Title slide, poster, first screen of the app |
| `vytra_app_icon_light.png` | Adaptive / launcher on light |
| `vytra_app_icon_dark.png` | Dark splash only |
| `vytra_logo_source.jpg` | Archive. Includes designer notes — **do not ship** |

The same files live in `vytra-college-submission/brand/`.

---

## 1. What the mark is

- A forest-green **V**
- A lime **leaf-pulse** (heartbeat + leaf) cutting through the V
- A lime **dot** at the upper right (a living point / reading)
- Wordmark **vytra** in lowercase, same forest green
- Category line **AI HEALTH SCREENING** in tracked small caps

Concept (for designers only, never printed in the app or on a result): vitality + a clinical *signal*, not a diagnosis.

---

## 2. Colour (sampled from the artwork)

| Token | Hex | Role |
|---|---|---|
| `color.forest` | `#0E2A1C` | V, wordmark, headers |
| `color.pulse` | `#6CA532` | Pulse, dot, tagline accent |
| `color.brand` | `#0E2A1C` | Replaces the old teal `#0B6E4F` for chrome |
| `color.brandInk` | `#FFFFFF` | Text on forest |
| `color.brandSoft` | `#E8F3DC` | Soft chips, selected state |
| `color.bg` | `#FFFFFF` | Logo always sits on white or very near-white |

Do not recolour the pulse to brand-teal. The two greens are the identity.

---

## 3. How the name is written

| Context | Form |
|---|---|
| Logo / splash / home header | The **PNG lockup**. Never typeset “VYTRA” next to a homemade V. |
| SIH / college forms, team name | `VYTRA` (unique, no college in the name) |
| Sentences in docs and scripts | VYTRA |
| In-app text if the image cannot load | `vytra` lowercase, Noto Sans Medium — fallback only |

---

## 4. Where each line may appear

| Line | Allowed | Forbidden |
|---|---|---|
| Mark + **vytra** lockup | Splash, S01, S02, PPT title, PDF header (small) | On top of a photograph, on a risk tile |
| **AI HEALTH SCREENING** | Under the lockup on S01 / title slide | Result screen, PDF body, consent |
| *See Health. Detect Early.* | S01, S02, splash, under the lockup | Result screen, PDF |
| “leaf-pulse concept — vitality + diagnostics” | Nowhere in the product | **Nowhere.** It is a designer note. The word **diagnostics** is banned on worker surfaces. |
| Vision + Vitality + Tracking + AI | Pitch deck only | Worker app |

---

## 5. Clear space and mistakes

- Keep clear space around the lockup equal to the height of the green dot.
- Do not outline, bevel, add a drop shadow, or put the mark on a busy photo.
- Do not separate the pulse from the V.
- Do not replace the pulse with a medical caduceus or a red cross.
- On dark backgrounds use `vytra_app_icon_dark.png` or a white plate behind the lockup. Do not invert the greens.

---

## 6. App icon

Launcher = `vytra_mark.png` on a white rounded square (Android adaptive: foreground = mark, background = `#FFFFFF`).

Safe zone: the V and the dot must stay inside the 66 % centre. Do not add the wordmark on the small icon — it will collapse.
