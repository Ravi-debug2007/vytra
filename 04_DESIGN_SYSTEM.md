# 04 — Design System

VYTRA is used outdoors, in dim rooms, and by workers who may not read English fluently. The UI is **large, high-contrast, icon-first, and calm**. It must not look like a consumer wellness app and must not look like a hospital EHR.

---

## 1. Principles

1. **One primary action per screen.**
2. **Icons carry the verb; text confirms it.**
3. **Risk is a shape first, a colour second.**
4. **The disclaimer is a product surface, not a footnote.**
5. **No decoration that costs FPS on the camera screens.**

---

## 2. Colour tokens

Use these exact hex values. Dark mode is **out of v1** — the camera preview is already dark; the chrome around it is dark; the rest of the app is light.

### 2.1 Brand and chrome

| Token | Hex | Use |
|---|---|---|
| `color.bg` | `#F8FAFC` | App background |
| `color.surface` | `#FFFFFF` | Cards, sheets |
| `color.ink` | `#0F172A` | Primary text |
| `color.inkMuted` | `#475467` | Secondary text |
| `color.line` | `#E4E7EC` | Dividers, input borders |
| `color.forest` | `#0E2A1C` | Official mark / wordmark |
| `color.pulse` | `#6CA532` | Leaf-pulse, tagline, accents |
| `color.brand` | `#0E2A1C` | Primary buttons, headers |
| `color.brandInk` | `#FFFFFF` | Text on brand |
| `color.brandSoft` | `#E8F3DC` | Selected chip background |
| `color.focus` | `#6CA532` | Focus ring, 2 dp |

### 2.2 Risk (fill / on-fill / container)

| Token | Fill | On-fill | Container |
|---|---|---|---|
| `risk.high` | `#B42318` | `#FFFFFF` | `#FEF3F2` |
| `risk.moderate` | `#B54708` | `#FFFFFF` | `#FFFAEB` |
| `risk.low` | `#027A48` | `#FFFFFF` | `#ECFDF3` |
| `risk.unable` | `#475467` | `#FFFFFF` | `#F2F4F7` |

Banner (HIGH present): background `risk.high.container`, text `risk.high`, 14 sp semibold.

### 2.3 Quality lamps

| State | Token | Hex |
|---|---|---|
| pass | `lamp.ok` | `#027A48` |
| fail | `lamp.bad` | `#B42318` |
| idle | `lamp.idle` | `#98A2B3` |

### 2.4 Camera chrome

| Token | Hex |
|---|---|
| `camera.scrim` | `#000000` 55 % |
| `camera.guide` | `#FDE68A` |
| `camera.guideOk` | `#6EE7B7` |
| `camera.shutter` | `#FFFFFF` |
| `camera.shutterDisabled` | `#FFFFFF` 35 % |

Do not use pure `#00FF00` guides. They bloom on cheap sensors.

### 2.5 Contrast

All text on its background ≥ **4.5:1**. Disclaimer on `color.bg` is `color.ink`, never `color.inkMuted`.

---

## 3. Typography

Embed:

- `assets/fonts/NotoSans-Regular.ttf`
- `assets/fonts/NotoSans-SemiBold.ttf`
- `assets/fonts/NotoSansTelugu-Regular.ttf`
- `assets/fonts/NotoSansTelugu-SemiBold.ttf`
- `assets/fonts/NotoSansDevanagari-Regular.ttf`
- `assets/fonts/NotoSansDevanagari-SemiBold.ttf`

`ThemeData.fontFamily` switches with locale: Noto Sans for `en`, Noto Sans Telugu for `te`, Noto Sans Devanagari for `hi`. Do not use Roboto for Telugu or Hindi.

| Style | Size / height / weight | Use |
|---|---|---|
| `display` | 28 / 34 / 600 | Home title only |
| `title` | 22 / 28 / 600 | Screen titles |
| `titleSm` | 18 / 24 / 600 | Card titles, risk label |
| `body` | 16 / 24 / 400 | Consent, instructions |
| `bodySm` | 14 / 20 / 400 | Helper text, next action |
| `disclaimer` | **12 / 16 / 400** | Locked disclaimer (minimum) |
| `label` | 14 / 20 / 600 | Buttons, chips |
| `mono` | 12 / 16 / 400 Noto Sans | Research numbers only |

Buttons: 16 sp semibold, 56 dp min height, 12 dp corner.

---

## 4. Spacing and shape

4 dp grid.

| Token | dp |
|---|---|
| `space.xs` | 4 |
| `space.sm` | 8 |
| `space.md` | 16 |
| `space.lg` | 24 |
| `space.xl` | 32 |
| `radius.sm` | 8 |
| `radius.md` | 12 |
| `radius.lg` | 20 |
| `radius.pill` | 999 |

Screen padding: 16 dp. Primary button: full width minus 32, 56 tall, 12 radius.

Minimum tap target: **48 × 48**. Capture shutter: **72 × 72**.

---

## 5. Elevation

One shadow only, for the home CTA and result tiles:

`0 1 2 0 #1018280D` and `0 1 3 0 #1018281A`.

No blur-heavy shadows on camera screens.

---

## 6. Result-screen layout contract (720×1280)

This is a hard layout. Measure on a 360×640 dp emulator.

```
0    app bar 56
56   8 gap
64   banner (0 if not HIGH, else 64)
     8 gap
     two tiles in a row
         tile height 168
     12 gap
     disclaimer block
         English ~ 5 lines × 16 = 80
         Telugu  ~ 6 lines × 16 = 96   ← design for 96
     12 gap
     button row 56
     16 bottom inset
```

Budget: 56+8+64+8+168+12+96+12+56+16 = **496 dp**. Fits in 640 with ~144 dp spare when the banner is present. If a future translation exceeds 96 dp, **reduce tile height**, never disclaimer size.

Test widget: `test/disclaimer_layout_test.dart` pumps S08 at 360×640 with `te` and `en` for every risk pair including dual HIGH + one UNABLE.

---

## 7. Components

### 7.1 `VytraButton`

| Variant | Background | Foreground |
|---|---|---|
| primary | `color.brand` | `color.brandInk` |
| secondary | `color.surface` + 1.5 dp `color.line` | `color.ink` |
| danger | `color.surface` + `risk.high` border | `risk.high` |

Disabled: 40 % opacity, not a different hue.

### 7.2 `RiskTile`

Width: `(360 - 32 - 12) / 2 = 158`. Icon 40 dp on top, label, then action in `bodySm`. Shape from §3 of `03_SCREENS_AND_STATES.md`.

### 7.3 `LampRow`

Horizontal, icon 20 + 6 + label. Pass = `lamp.ok`, fail = `lamp.bad`. Animate colour 150 ms, not position.

### 7.4 `GuideEllipse`

2.5 dp stroke, dash 8/6. Colour `camera.guide`, switches to `camera.guideOk` when all gates pass. Centered, width 72 % of preview, height 48 % of preview (anemia, lid is wide). Jaundice: same ellipse but a 4 dp solid arc on the **temporal** third (the third toward the frame edge).

### 7.5 `ConsentBody`

Plain `Text`, no Markdown widgets, no HTML. Paragraph spacing 12.

---

## 8. Illustration style

If a coaching illustration is needed (lid pull, look-to-nose), use a single-weight line drawing, 2 dp, `color.ink`, no skin-tone realism, no blood. One illustration per capture series, shown above the preview on first entry, dismissed by “Got it.”

Do not use stock photos of eyes.

---

## 9. App icon and splash

- Icon: dark-green rounded square, simple eye mark, no wordmark, no red cross, no caduceus.
- Splash: `color.bg` + eye mark + **VYTRA** + tagline `See Health. Detect Early.` + localised `languageFooter` underneath in `bodySm`.
- Wordmark is always **VYTRA** in uppercase, tracking +40, Noto Sans SemiBold. Do not set it in title case (`Vytra`) or with a hyphen.
- The black brand card (eye + white type) is for the pitch deck and store listing. The **in-app field UI stays light** (`color.bg`) so outdoor glare does not kill contrast.
- Optional dark splash (2 s) may use `#0B0B0B` + white wordmark to match the brand card, then fade to the light S01/S02.

Adaptive icon foreground safe zone 66 %.

---

## 10. What this is not

- No Material 3 tonal-palette generation that would recolour risk reds.
- No inter / poppins / montserrat. Indic shaping is why we embed Noto.
- No glassmorphism over the camera.
- No Lottie on the result screen.
