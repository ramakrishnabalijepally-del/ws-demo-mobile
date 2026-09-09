---
trigger: model_decision
description: Apply when building, styling or reviewing any WorkSettle UI — screens, navigation, buttons, chips, cards, forms, progress, chat, brand colour or typography. The binding brand contract.
---

# WorkSettle — brand and design contract (mobile)

## The source of truth

**[`design/worksettle-design-system-minimal-v1.md`](../../design/worksettle-design-system-minimal-v1.md)
— WorkSettle Design System v1.0, Minimal edition.** Read it before designing
anything. It is the primary lookup for every colour, type step, radius, spacing
value, component spec, state rule, copy rule and contrast pair.

**This file is a binding condensation, not a replacement.** Where this file is
silent, the design system decides. Where they disagree, **the design system
wins** — and this file is then wrong and gets fixed. Where the design system
and a design skill disagree, the design system wins (`05-reuse-and-skills.md`).

The `Screenshots/` folder is a **feature inventory only**. Those images come
from a blue job-portal template and an older red deck; **neither palette is
used**. They tell you which screens exist, never what they look like.

The same brand system is mirrored in `ws-frontend` and `ws-marketing`. A change
to it belongs in all three (`07-collaboration.md`).

---

## What this replaces

The pre-design-system version of this file was wrong on six counts. If you have
seen it, or carry it in training priors, these are **no longer true**:

| Obsolete | Now |
|---|---|
| Seven feature accent hues (blue, green, purple, cyan, amber, pink) | **Retired.** Modules are ink `#111111` on Grey 100 `#F4F4F4` and are told apart by their glyph. Job Matching alone keeps Settle Red. |
| CTAs are rounded rectangles, never pills | **Every button is a full pill** (999 px) |
| Status colours: green / blue / amber | **No hue.** Filled → outlined → tinted, every chip carrying a mandatory glyph |
| `--primary` ≈ `#E11B22`, measured | **`#E4101B`**, exact, with a ten-step ramp |
| Light-only; no dark theme | Dark is a **full second theme** (`03-styling.md` rule 5) |
| A cool, blue-leaning grey | A **true neutral** at zero saturation |

Delete rather than reconcile.

---

## Colour — one red, one grey, nothing else

Colour is a single bit: **red or not red**. Red means *this is the brand, or
this is the thing to press* — and never anything else. Every other distinction
is drawn with **weight, fill, size, icon and position**.

- **Settle Red `#E4101B`** — all primary fills, active nav, tab underline,
  focus ring, tints. Ramp: 100 `#FBE7E8` · 200 `#F5CDCF` · 300 `#EDA3A6` ·
  400 `#EE6A6F` · 500 `#F0353C` · **base** · 600 `#F0272E` · 700 `#B00A13` ·
  800 `#7E060D` · 900 `#4A0308`.
- **Logo red `#b80404`** lives inside the supplied logo file **and nowhere
  else**. It is not a token. Nobody "corrects" it to match Settle Red, or the
  other way round.
- **Grey, true neutral** — 0 `#FFFFFF` · 50 `#FAFAFA` · 100 `#F4F4F4` ·
  200 `#E6E6E6` · 300 `#D1D1D1` · 400 `#A3A3A3` · 500 `#757575` · 600 `#525252`
  · 700 `#3D3D3D` · 800 `#262626` · 900 `#111111` · 950 `#000000`.

**No second accent hue enters this system.** No green, amber, blue, purple or
teal — not for a status, not for a module, not for a chart, not "just this
once".

**Red is never a state colour.** An immigration app that flashes red at people
reads as rejection. The single exception is form validation: Red 700 text on a
Red 100 field tint, always with an icon and a full sentence.

---

## State — the three-rung ladder

| State | Chip | Glyph | Reads as |
|---|---|---|---|
| Eligible · Good Range · High Potential · Good Match | Solid ink fill, surface label | check | settled |
| Potential Match · Potential Options | White fill, 1 px Grey 300 border, Grey 700 label | half-circle | in progress |
| Explore Further · not yet assessed | Grey 100 fill, no border, Grey 600 label | dot | quiet |

Filled outranks outlined outranks tinted. **Every state chip carries its glyph
— a chip without one is a bug**, because with hue removed the glyph is the
second channel. The wording above is the complete set of verdicts the product
may show. **A pill never says "Ineligible"**: show the neutral verdict plus the
specific gap and what closes it.

---

## Type — Plus Jakarta Sans

| Role | Size / line | Weight | Tracking |
|---|---|---|---|
| display | 28 / 34 | 800 | −0.03em |
| title-lg | 22 / 28 | 800 | −0.025em |
| title | 17 / 23 | 700 | −0.015em |
| metric | 26 / 30 | 800 | −0.03em, tabular |
| body | 15 / 23 | 500 | 0 |
| label | 13 / 18 | 700 | 0 |
| caption | 12 / 17 | 500 | 0 |
| overline | 10 / 12 | 700 | +0.12em |

Headings are never centred except on the three full-screen moments: welcome,
account created, subscription success. In the positioning line only the words
**Work & Immigration** take the red — the emphasis is fixed, not a free
highlight.

---

## Space, radius, elevation

4 px base. Gutter 20, card padding 16, gap between cards 12.
Radii: **pill 999 · card 16 · row 14 · field 12 · tile-sm 10 · checkbox 6** —
the radius encodes what the thing is (`03-styling.md` rule 5b).

The product is nearly flat: **the hairline is the boundary, the shadow only
says how far off the ground.** The one exception is the primary button, which
carries a red shadow (8 blur, 2 down, Settle Red 28%) dropped on press.

---

## Components — build each once

Full specs in the design system §8–§17. The binding shape:

- **Buttons** (§8) — primary (red pill, white label, trailing arrow when it
  moves you forward), secondary (red border), ghost (Grey 200 border, never
  alone), link, and the 44 px red circular send — **the only circle in the
  system**. Two primary buttons never appear on one screen.
- **Icon tiles** (§10) — 44/12/22 rows and hub, 40/10/20 compact,
  60/999/28 module screen header.
- **Cards** (§11) — one shell: surface, 16 px, hairline, 16 px padding. Score,
  selection (2 px red border + `#FDF3F3`, padding −1 px so nothing shifts),
  plan, banner (the **only** gradient, 103°, `#FDF4F4`→`#F7F7F7`).
- **Forms** (§12) — the label sits **above** the field and stays visible. Never
  a floating or placeholder label. Error text below, naming the fix.
- **Progress** (§13) — six devices, each answering a different question:
  segment bar (long form) · dot rail (few steps) · numbered stepper (named
  steps) · meter (score vs max) · **ring (completeness only — profile strength
  is the only ring in the product)** · processing timeline (what the AI is
  doing now, instead of a spinner).
- **Conversation** (§15) — user bubble ink, assistant bubble Grey 100; the
  assistant never speaks in brand red. Answers carrying a score render a **real
  score card inside the bubble**, not text. Voice mode inverts to `#000000`.
- **Comparison** (§16) — absence is an **em dash**, never a cross and never a
  red X. The product does not punish the cheaper choice visually.
- **Success** (§17) — a **red ring** marks a step completed; a **filled ink
  disc** marks a transaction settled. Confetti on three screens only.

---

## Navigation — five destinations, fixed for the life of the app

**Home · Jobs · Immigration · Settlement · Profile.** Everything else is
reached from inside one of them, as a `StatefulShellRoute` branch so each tab
keeps its own stack. Active icon and label both go Settle Red; inactive is
Grey 500; **labels never hide**.

Tabs inside a screen: scrollable, at most five, active is Settle Red with a
2.5 px underline — the underline is the only indicator, no pill and no fill.

A list row's chevron means the row opens a screen. **A row without a chevron is
not tappable.**

---

## Voice and content (§20)

Address the reader as **you**, the product as **WorkSettle** — never "we" for
the AI. Give a number its context in the same breath: *"468 — competitive for
recent draws of 435–470"*. Name the fix, not the failure: *"Enter your date of
birth as YYYY-MM-DD"*, never *"Invalid input"*.

**Never state an immigration outcome as certain.** Results are initial and
based on what the user provided; final eligibility rests with IRCC or the
province. This is a legal and a trust requirement, and it belongs in the
component — the result card carries the disclaimer slot so no screen can forget
it.

---

## Accessibility (§21)

48 dp minimum on every control, chevron rows included. Every verdict pairs
colour with a word. Every icon-only control is labelled for screen readers. The
2 px red focus ring is the only focus style. 200% text scaling is supported —
cards grow, they do not clip. Never set body copy in Grey 400 (2.52:1) or
paragraph text in the base red.

**The system passes a greyscale test**: no information anywhere depends on
colour vision. Keep it that way — if a screen needs hue to be legible, the
screen is wrong.

---

## Still open (design system §23)

Not yet defined by the client, so build minimally and flag rather than invent:
empty and error states for job and appointment lists · skeleton loading ·
tablet and web breakpoints · French localisation of the fixed verdict pills ·
the document-upload component.

Assets not yet supplied: `worksettle.svg` and `worksettle-reverse.svg`
(**never redraw the wordmark**), Plus Jakarta Sans, photography, province and
country marks.

Related: `03-styling.md` · `04-animation.md` · `05-reuse-and-skills.md` ·
`06-quality-and-verification.md` · `07-collaboration.md`
