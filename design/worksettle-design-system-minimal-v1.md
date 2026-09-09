# WorkSettle Design System

**Version 1.0 — Minimal edition** · Derived from the Platform Design deck (7 boards, 48 screens)

WorkSettle is Canada's first AI platform for work and immigration settlement. This document is the
visual and interaction system behind it. Every value here was sampled from the design deck — the
onboarding flow, the profile dashboard, the CRS and PNP calculators, the AI assistant, and the
subscription funnel — so the system describes what was actually drawn, not an idealised version of it.

This is the **minimal edition** of the system. It is the same product, the same structure and the
same rules as the full system — with one change at the foundation: the palette is **red, black, white
and shades of those three, and nothing else**. The seven-hue module spectrum is retired, the
green/amber/blue semantic hues are retired, and the cool blue-leaning slate is replaced by a true
neutral grey. What used to be carried by hue is now carried by weight, fill, icon and position. The
result is quieter, more modern and reads as more professional in a document- and money-adjacent
product.

This document describes the design only. It names colours, sizes, states and rules — not the code that
implements them — so it can be read the same way whatever the app is built with. The interactive
version has live swatches and click-to-copy values.

---

## Contents

**Foundations** — [Brand](#1-brand) · [Color](#2-color) · [Dark theme](#dark-theme) · [Module marks](#3-module-marks) · [Typography](#4-typography) · [Space & radius](#5-space--radius) · [Elevation](#6-elevation) · [Iconography](#7-iconography)

**Components** — [Buttons](#8-buttons) · [Pills & badges](#9-pills--badges) · [Icon tiles](#10-icon-tiles) · [Cards](#11-cards) · [Forms](#12-forms) · [Progress](#13-progress) · [Navigation](#14-navigation) · [Conversation](#15-conversation) · [Comparison](#16-comparison) · [Feedback](#17-feedback--milestones)

**Applied** — [Composed screen](#18-composed-screen) · [Patterns](#19-patterns) · [Voice & content](#20-voice--content) · [Accessibility](#21-accessibility) · [Screen inventory](#22-screen-inventory) · [Provenance](#23-provenance)

---

## 1. Brand

WorkSettle is a companion for people making one of the largest decisions of their lives. The identity
is warm and Canadian without being bureaucratic: a confident red, a lot of white, and copy that speaks
in the second person.

### Wordmark

The artwork is supplied by the client as `worksettle.svg`, with `worksettle-reverse.svg` for dark
grounds. It is a fixed asset: set it, scale it, but never redraw it, re-letter it or re-colour it.

| Element | Rule |
|---|---|
| **Two-tone letters** | The capitals carry the red and the lowercase carries the ink: **W** red, "ork" black, **S** red, "ettle" black. It is not "Work" red and "Settle" black — the split falls inside each word, which is what makes the two capitals read as one mark. |
| Globe | Sits inside the **o** of "Work": a filled disc with red continents. It is part of the letterform, never a separate icon and never lifted out on its own. |
| Figures | Three small figures — one ink, flanked by two red — sit in a break in the rule below the wordmark. They are the only illustrative element in the identity. |
| Rule | A hairline runs the width of the wordmark, broken in the centre to hold the figures. |
| Tagline | "Your Journey Starts Here" sits under the rule, centred, bold, in ink. Never set in red. |
| Clear space | Minimum of one cap height of the "W" on all four sides. |
| Minimum size | 96 px wide on screen. Below that, drop the tagline and the rule and set the wordmark alone. |
| Reversed | On Grey 900 and darker, the ink becomes white and the red lightens to `#EF4444`. Nothing else changes. Use the supplied reversed file — do not apply a filter to the primary one. |

### Files

| File | Use |
|---|---|
| `worksettle.svg` | Primary lockup, for white and light grounds. Ships with an opaque white background. |
| `worksettle-reverse.svg` | Reversed lockup, transparent background, for Grey 900 and darker. |

### Brand lines

| Slot | Line |
|---|---|
| Tagline | Your Journey Starts Here |
| Product promise | One Profile. Endless Opportunities. |
| Journey rail | WORK · IMMIGRATE · SETTLE |
| Positioning | Canada's first AI platform for **Work & Immigration** settlement. |

In the positioning line, only the words **Work & Immigration** take the red. The emphasis is a fixed
part of the sentence, not a free highlight.

---

## 2. Color

**One red, one grey ramp, and nothing else.** Settle Red carries the brand and every primary action;
everything else is a true neutral grey running from white to black. There is no second accent hue
anywhere in the product, so the red never competes with anything and always means the same thing:
*this is the brand, or this is the thing to press*.

The discipline this buys is worth stating plainly. In a system with seven module hues plus green,
amber and blue semantics, a screen can carry four unrelated colours and none of them mean anything
in particular. Here, colour is a single bit — red or not red — and every other distinction is drawn
with **weight, fill, size, icon and position**, which are cheaper to read and never fail a colour
test.

### Primary — Settle Red

| Name | Hex | Use |
|---|---|---|
| Red 100 | `#FBE7E8` | Tinted backgrounds, icon tiles, selected-card fill |
| Red 200 | `#F5CDCF` | Secondary button pressed |
| Red 300 | `#EDA3A6` | Disabled fill |
| Red 400 | `#EE6A6F` | Accent on dark surfaces |
| Red 500 | `#F0353C` | Dark-mode accent |
| **Settle Red** | **`#E4101B`** | **Brand. All primary fills, active nav, tab underline** |
| Red 600 | `#F0272E` | Primary hover |
| Red 700 | `#B00A13` | Primary pressed; red text at body size |
| Red 800 | `#7E060D` | Text on Red 100 |
| Red 900 | `#4A0308` | Deepest shade |

**500 is not the base.** The brand red `#E4101B` sits between 500 and 600 because it was sampled from
the filled CTA buttons across all seven boards, which ranged from `#DA191C` to `#F30618` under
compression.

### Logo red — a deliberate exception

The client artwork is drawn in **`#b80404`**, a deeper and browner red than Settle Red. **This is
intentional and stays that way.** Settle Red is the interface colour — buttons, active nav, tab
underlines, tints; `#b80404` belongs to the logo file alone and is never used anywhere else in the
product. Nobody should "correct" either one to match the other: the logo is fixed artwork, and the
interface red was chosen to carry white text at small sizes, which is a different job.

| Red | Value | Where it may appear |
|---|---|---|
| Settle Red | `#E4101B` | Every interface use — buttons, active nav, tab underline, tints, focus ring |
| Logo red | `#b80404` | Inside the supplied logo file only. Never as a fill, text or border anywhere else |
| Logo red, reversed | `#EF4444` | Inside the reversed logo file only. `#b80404` measures 2.54:1 on a dark card, which is why the reversed artwork lightens it |

### Neutral — Grey

A **true neutral** at zero saturation. The full system leaned its greys a few degrees toward blue;
this edition does not, because a blue cast is itself a colour, and next to a warm red it reads as a
second hue rather than as neutral. Pure grey lets the red sit on it cleanly and keeps screenshots,
exports and print behaving predictably.

| Name | Hex | Use |
|---|---|---|
| Grey 0 | `#FFFFFF` | Cards, sheets, app bar |
| Grey 50 | `#FAFAFA` | Screen ground behind cards |
| Grey 100 | `#F4F4F4` | Assistant bubble, neutral pill, inactive tile |
| Grey 200 | `#E6E6E6` | Every hairline border and progress track |
| Grey 300 | `#D1D1D1` | Radio and checkbox rest ring, home indicator |
| Grey 400 | `#A3A3A3` | Placeholders, chevrons, decorative icons |
| Grey 500 | `#757575` | Supporting copy, captions, inactive nav |
| Grey 600 | `#525252` | Body copy on cards |
| Grey 700 | `#3D3D3D` | Emphasised body |
| Grey 800 | `#262626` | Field labels |
| Grey 900 | `#111111` | All headings, primary text, user chat bubble |
| Grey 950 | `#000000` | Voice mode, dark hero grounds |

### Semantic

| Name | Hex | Meaning |
|---|---|---|
The three semantic roles survive as *roles* — the names still mean the same thing — but they now
resolve to steps on the grey ramp rather than to hues.

| Name | Hex | Meaning |
|---|---|---|
| Success 500 | `#111111` | Eligible, qualified, complete — the solid fill of a filled chip |
| Success 100 | `#EDEDED` | Quiet success tint, used behind long-form confirmations only |
| Success 700 | `#111111` | Success label |
| Warning 500 | `#757575` | Potential, needs more input — the border and glyph of an outlined chip |
| Warning 100 | `#FAFAFA` | Reserved; an outlined chip has no fill |
| Warning 700 | `#3D3D3D` | Potential label |
| Info 500 | `#525252` | Neutral information, links in body |
| Info 100 | `#F4F4F4` | Info tint, Pro+ column |
| Info 700 | `#262626` | Info text on tint |

**State is carried by weight and fill, not by hue.** There is no green and no amber. The three
levels are told apart the way type is told apart — by how solid they are:

| State | Chip | Glyph | Reads as |
|---|---|---|---|
| **Eligible, qualified, complete** | Solid ink fill, white label | Check | Settled, finished |
| **Potential, needs more input** | White fill, 1 px grey border, grey label | Half-circle | Open, in progress |
| **Neutral information, no signal yet** | Grey 100 fill, no border, grey label | Dot or info | Quiet, background |

A filled chip always outranks an outlined one, and an outlined one always outranks a tinted one. That
ladder is legible at a glance, survives greyscale printing and monochrome displays, and never asks
anyone to remember what a colour meant.

**Every state chip carries a glyph.** In the full system the glyph was reinforcement on top of hue;
here it is load-bearing, so it is not optional — a chip without its icon is a bug.

**Red is still reserved for brand and action — it is never a state colour**, because an immigration
app that flashes red at people reads as rejection. The one exception is unchanged: validation errors
use Red 700 text with a Red 100 field tint, always with an icon and a full sentence.

### Surfaces

| Name | Hex | Use |
|---|---|---|
| Surface | `#FFFFFF` | Cards, sheets, app bar |
| Ground | `#FAFAFA` | Screen background behind cards |
| Surface — selected | `#FDF3F3` | Selected card tint |
| Surface — inverse | `#111111` | Chat bubble, dark hero |

### Dark theme

Dark is a full second theme, not a filter over the light one. The rule that shapes it: **the ramp
inverts, the brand red does not.** Settle Red keeps its exact value wherever it fills a shape — a
primary button is `#E4101B` with a white label in both themes, so the product's one loud object looks
the same to everyone. What changes is red used as *text, border or icon*, which vibrates badly on a
dark ground: that lightens to `#EE6A6F`.

| Role | Light | Dark |
|---|---|---|
| Ground behind cards | `#FAFAFA` | `#0A0A0A` |
| Card, sheet, app bar | `#FFFFFF` | `#141414` |
| Assistant bubble, neutral pill | `#F4F4F4` | `#1C1C1C` |
| Hairline border, progress track | `#E6E6E6` | `#2A2A2A` |
| Control rest ring | `#D1D1D1` | `#3D3D3D` |
| Placeholder, decorative icon | `#A3A3A3` | `#707070` |
| Supporting copy, caption | `#757575` | `#969696` |
| Body copy | `#525252` | `#B5B5B5` |
| Field label | `#262626` | `#E0E0E0` |
| Heading, primary text | `#111111` | `#F5F5F5` |
| Voice mode ground | `#000000` | `#000000` |
| Selected card tint | `#FDF3F3` | `#2A1011` |

Grey 950 barely moves. It is the voice-mode ground, and voice mode is dark in both themes — the one
place where the two themes converge rather than invert.

**Red**

| Use | Light | Dark |
|---|---|---|
| Filled action, active fill, checked control | `#E4101B` | `#E4101B` — unchanged |
| Label on that fill | `#FFFFFF` | `#FFFFFF` |
| Red as text, border, icon, active nav | `#B00A13` at body size | `#EE6A6F` |
| Tinted background | `#FBE7E8` | `#2E1213` |

**Semantic and module colours** invert the same way: the `100` tints become deep, low-chroma grounds
and the text step lightens, so a pill stays a quiet chip rather than a glowing one.

| Role | Light tint / solid / text | Dark tint / solid / text |
|---|---|---|
| Success | `#EDEDED` / `#111111` / `#111111` | `#1C1C1C` / `#F5F5F5` / `#F5F5F5` |
| Warning | `#FAFAFA` / `#757575` / `#3D3D3D` | `#161616` / `#969696` / `#CACACA` |
| Info | `#F4F4F4` / `#525252` / `#262626` | `#1C1C1C` / `#B5B5B5` / `#E0E0E0` |

| Module | Light base / tint | Dark base / tint |
|---|---|---|
| Job Matching | `#E4101B` / `#FBE7E8` | `#EE6A6F` / `#2E1213` |
| Profile Matching | `#111111` / `#F4F4F4` | `#F5F5F5` / `#1C1C1C` |
| Immigration Eligibility | `#111111` / `#F4F4F4` | `#F5F5F5` / `#1C1C1C` |
| CRS Predictor | `#111111` / `#F4F4F4` | `#F5F5F5` / `#1C1C1C` |
| AI Voice & Chat | `#111111` / `#F4F4F4` | `#F5F5F5` / `#1C1C1C` |
| Smart Checklist | `#111111` / `#F4F4F4` | `#F5F5F5` / `#1C1C1C` |
| Appointments | `#111111` / `#F4F4F4` | `#F5F5F5` / `#1C1C1C` |

**The chat inverts with the theme, and that is intentional.** The user's bubble is always the ink
step and the assistant's is always the neutral step — so in dark mode the user speaks in a near-white
bubble with dark text. The relationship survives; the colours swap.

**Column and card tints** are the palest surfaces in the product, so they invert to the deepest. The
Pro column keeps the faintest trace of red — it is the plan the brand pushes — and everything else is
flat neutral grey. That single warm surface against neutral ones is the whole of the differentiation,
and it is enough.

| Surface | Light | Dark |
|---|---|---|
| Plan matrix — Pro column | `#FDF4F4` | `#1E1414` |
| Plan matrix — Pro+ column | `#F6F6F6` | `#171717` |
| Score breakdown card | `#F7F7F7` | `#161616` |

**What does not have a dark variant:** the banner gradient is re-cut rather than inverted
(`#2A1011 → #1C1C1C`), and the CN Tower photography keeps its scrim in both themes. Full-colour
province and country marks are never recoloured for dark.

---

## 3. Module marks

**The seven-hue spectrum is retired.** In the full system each module owned a colour — blue, teal,
purple, cyan, orange, pink — and that was the wayfinding device. It is gone here, for three reasons:
six arbitrary hues carry no meaning a user can learn; they force every screen to host a colour that
competes with the red; and they age badly, because the spectrum has to be re-cut every time a module
is added.

**Modules are now told apart by their glyph.** Every module tile is the same ink glyph on the same
Grey 100 tile, and the icon does the identifying — which is what it was already doing. The one
exception is Job Matching, which keeps the brand red: it is the entry point to the product and the
place the brand should appear.

| Module | Base | Tint | What it does |
|---|---|---|---|

| Module | Base | Tint | What it does |
|---|---|---|---|
| Job Matching | `#E4101B` | `#FBE7E8` | Verified, immigrant-friendly employers |
| Profile Matching | `#111111` | `#F4F4F4` | AI matches profile to career and PR paths |
| Immigration Eligibility | `#111111` | `#F4F4F4` | PR, PNP and federal program assessment |
| CRS Predictor | `#111111` | `#F4F4F4` | Score estimate against recent draws |
| AI Voice & Chat | `#111111` | `#F4F4F4` | Answers on jobs, immigration, settlement |
| Smart Checklist | `#111111` | `#F4F4F4` | Personalised step-by-step plan |
| Appointments | `#111111` | `#F4F4F4` | Consultations with licensed RCICs |

The tint fills the icon tile; the base sits on the glyph and any progress bar. **Module colour never
fills a button** — every primary action in the product is Settle Red, including inside a module.

Because the tiles no longer differ by hue, the **glyph set has to work harder**: each of the seven
must be distinguishable in silhouette at 20 px, and no two may share a dominant shape. Test them as a
row of seven at final size before adding an eighth.

---

## 4. Typography

One family across the whole product. The screens use a geometric humanist sans with heavy display
weights and open counters; **Plus Jakarta Sans** matches it closely and covers the Latin Extended
range the product needs for French, Punjabi transliteration and name fields.

| Role | Size / line | Weight | Tracking | Used for |
|---|---|---|---|---|
| **display** | 28 / 34 | 800 | −0.03em | Screen titles — "Let's Get You Started", "Choose Your Plan" |
| **title-lg** | 22 / 28 | 800 | −0.025em | Section headings inside a screen |
| **title** | 17 / 23 | 700 | −0.015em | Card titles, app bar title, module names |
| **metric** | 26 / 30 | 800 | −0.03em | Scores. Tabular figures; denominator at 14 px / 600 in Grey 500 |
| **body** | 15 / 23 | 500 | 0 | Running copy, list rows, field values |
| **label** | 13 / 18 | 700 | 0 | Field labels, tab labels |
| **caption** | 12 / 17 | 500 | 0 | Supporting lines under a title, helper text |
| **overline** | 10 / 12 | 700 | +0.12em | Uppercase eyebrows, bottom-nav labels |

Numbers that stack in a column — score breakdowns, price tables — always set
set in **tabular figures**, so digits share one width. Headings are never centred except on the three full-screen
moments: welcome, account created, and subscription success.

---

## 5. Space & radius

A **4 px base unit**. Screen gutters are 20 px, cards are padded 16 px, and the vertical rhythm
between stacked cards is 12 px.

| Name | Value | Use |
|---|---|---|
| Space 1 | 4px | Icon-to-label |
| Space 2 | 8px | Inside a pill |
| Space 3 | 12px | Between cards |
| Space 4 | 16px | Card padding |
| Space 5 | 20px | Screen gutter |
| Space 6 | 24px | Section gap |
| Space 8 | 32px | Above a bottom CTA |
| Space 12 | 48px | Around a full-screen glyph |

| Name | Value | Use |
|---|---|---|
| Pill | 999px | Buttons, pills, avatars, toggles |
| Card | 16px | Cards, banners, sheets |
| Row | 14px | List rows, composer |
| Field | 12px | Inputs, selects, icon tiles |
| Tile — small | 10px | Compact tiles, flag frames |
| Checkbox | 6px | Checkbox only |

**The radius encodes the shape of the thing.** Anything you press is a full pill; anything that holds
content is 16 px; anything you type into is 12 px. That difference is how a button and an input stay
distinguishable at a glance in a form.

---

## 6. Elevation

The product is nearly flat. Cards separate from the ground with a hairline border first and a shadow
second — the shadow alone is never the boundary.

| Level | Value | Use |
|---|---|---|
| Border only | 1 px solid #E6E6E6 | Default card |
| Raised | 2–3 px blur, 1 px down, ink at 5% | Score cards, plan cards |
| Floating | 14 px blur, 4 px down, ink at 9% | Bottom sheet, app bar on scroll |
| Modal | 40 px blur, 18 px down, ink at 18% over a 40% ink scrim | Dialogs |

The one exception is the primary button, which carries a coloured shadow — 8 px blur, 2 px down,
Settle Red at 28% — so the call to action lifts off a white screen. It drops to none on press.

**In dark mode a black shadow does nothing**, so elevation is carried by the hairline plus a 1 px
top highlight of white at 4–6% inside the top edge, with the shadow deepened to black at 55–72% to
hold the modal apart from the scrim. The ordering rule is unchanged: the border is the boundary, the
shadow only says how far off the ground the surface sits.

---

## 7. Iconography

Two icon styles, used for different jobs. **Solid** glyphs sit inside module tiles and the bottom nav;
**1.9 px stroked** outlines sit inside form fields and list rows where they must not compete with the label.

| Context | Size | Color |
|---|---|---|
| Module tile glyph | 22px | Module base on the module tint tile |
| Bottom nav | 21px | Settle Red active, Grey 500 rest |
| Field leading icon | 18px | Grey 400 |
| Row chevron | 16px | Grey 400 |
| Button trailing arrow | 17px | Inherits button text color |
| Checklist tick | 18px | Ink filled disc when done, Settle Red for brand-confirm |

Province and country marks are the only full-color imagery allowed in an icon slot. They sit in a
40 px rounded square with a Grey 200 hairline, never recolored and never cropped to a circle.

---

## 8. Buttons

Every button is a full pill. The product is a linear journey, so the primary action is almost always a
full-width button pinned to the bottom of the screen with a trailing arrow — **the arrow means "this
moves you forward"** and is dropped on actions that stay on the same screen.

| Button | Fill | Label | When |
|---|---|---|---|
| **Primary** | Settle Red, white label | 700 / 14.5px | The one forward action per screen. Full width in flows, inline in cards. |
| **Secondary** | Transparent, Settle Red border + label | 700 / 14.5px | The alternative route — voice instead of chat, detail instead of save. |
| **Ghost** | Transparent, Grey 200 border | 700 / 14.5px | Back, Cancel. Never sits alone. |
| **Link** | None, underlined Settle Red | 700 / 14px | Escape hatches — "Sign In", "Skip", "Go to Dashboard". |
| **Send button** | Settle Red circle, 44 px | Icon only | Chat send. The only circular button in the system. |

| State | Primary | Secondary |
|---|---|---|
| Rest | Settle Red + red shadow | transparent |
| Hover | Red 600 | Red 100 fill |
| Pressed | Red 700, shadow removed | Red 200 fill |
| Focus | 2px Settle Red ring, 2px offset — never the browser default | same |
| Disabled | 45% opacity, not interactive | same |
| Loading | Label swaps for a 3-dot pulse; width is held so the layout does not jump | same |

Minimum touch target is **48 px** tall including padding. Two primary buttons never appear on one screen.

---

## 9. Pills & badges

Eligibility is the product's core information, and a pill is how it is reported. The wording is fixed —
these are the only verdicts the product may show, so that a user learns to read them at a glance
across the CRS, PNP and comparison screens.

| Verdict | Style | Means |
|---|---|---|
| Eligible / Good Range / High Potential / Good Match | **Filled** — solid ink fill, surface-coloured label, check glyph | The user meets the published threshold on the data they have given. |
| Potential Match / Potential Options | **Outlined** — no fill, 1 px Grey 300 border, Grey 700 label, half-circle glyph | Possible, but depends on information not yet entered or a factor outside their profile. |
| Explore Further | **Tinted** — Grey 100 fill, no border, Grey 600 label, dot glyph | Not assessed. Never styled as a negative. |
| Most Popular | Settle Red fill, white label, no glyph | Commercial emphasis. One per plan list, never on an eligibility result. |
| Save 17% | Grey 100 fill, Grey 600 label | Pricing incentive on the yearly toggle — deliberately quiet, it is not a verdict. |

**Filled, outlined, tinted — that is the whole ladder**, and it is the same ladder everywhere in the
product: the more certain the state, the more solid the shape. No pill carries a hue, and every state
pill carries its glyph, because with colour removed the glyph is the second channel.

Spec: 700 weight at 11.5 px, 5 px vertical and 10 px horizontal padding, 1 px border (transparent
unless outlined), fully rounded, 12 px glyph at 5 px gap.

**A pill never says "Ineligible".** Where a user does not qualify, the screen shows the neutral verdict
plus the specific gap and what closes it — the assessment is provisional and the copy says so.

---

## 10. Icon tiles

The tile is the product's most repeated object: a rounded square filled with a module tint, holding
that module's glyph in its base color. It appears in the feature hub grid, in quick actions, on every
score card and at the head of every module screen.

| Size | Radius | Glyph | Where |
|---|---|---|---|
| 44 × 44 | 12px | 22px | Score cards, list rows, hub tiles |
| 40 × 40 | 10px | 20px | Quick actions, compact rows |
| 60 × 60 | 999px | 28px | Module screen header — the circle marks a full screen, not a row |

---

## 11. Cards

Four card types carry nearly every screen. They share one shell — the surface colour of the
current theme, 16 px radius, hairline border, 16 px padding — and differ only in what they hold.

### Score card

Icon tile · title · supporting line · metric with denominator · verdict pill · progress bar · context line.

The progress bar is ink on a Grey 200 track — it reports *how far*, never *how good*; only the pill
reports the verdict. The CRS bar is the one bar allowed to fill in **red**, because CRS is the
product's headline number and the screens treat it as the measure that matters most.

### Selection card

Selected is a **2 px red border plus the selected-surface tint** (`#FDF3F3` light, `#2A1011` dark), with the padding reduced by 1 px so the card
does not shift when it is chosen. This is the single most-used selection state in the product —
profile type, goals, plan and payment method all use it.

### Plan card

Name · optional "Most Popular" badge · price at 30 px / 800 with the period at 14 px / 600 in Grey 500 ·
one-line description · feature list with red ticks. Selected uses the selection-card treatment.

### Banner

The banner is the only surface allowed a gradient, and only this one: a 103° sweep from **#FDF4F4** to **#F7F7F7**, re-cut for dark as **#2A1011** to **#1C1C1C** rather
than inverted. It
carries good news at the top of a results screen. It has no border and no shadow.

---

## 12. Forms

Labels sit **above** the field, always visible — never a floating or placeholder label. People are
entering passport-accurate information under stress; the label must stay readable while they type.

| Element | Rest | Focus | Filled | Error |
|---|---|---|---|---|
| Input | 1.5px Grey 200 | Settle Red border + 3px Red 100 ring | Grey 900 text, 500 | Red 700 border, Red 100 fill |
| Radio | 2px Grey 300 ring | 3px Red 100 halo | Settle Red ring + 10px dot | Red 700 ring |
| Checkbox | 2px Grey 300, 6px radius | 3px Red 100 halo | Settle Red fill, white tick | Red 700 ring |

Field anatomy: label (13/700, Grey 800) → input row (12 px radius, 12–14 px padding, optional 18 px
leading icon in Grey 400) → helper or error text below.

Error text sits **below** the field at 12 px / 600 in Red 700 with a 14 px alert glyph, and names
the fix: *"Enter your date of birth as YYYY-MM-DD"*, not *"Invalid input"*. Helper text uses the same
slot in Grey 500; the two never appear at once.

The phone field carries a country flag and dial code inline before the input. The segmented toggle
(Monthly / Yearly) is a pill track in Grey 100 with the active segment filled Settle Red.

---

## 13. Progress

The product is a sequence of long forms and long processes, so it carries six distinct progress
devices. Each one answers a different question, and using the wrong one is the most common way a
screen becomes confusing.

| Device | Answers | Use in |
|---|---|---|
| Segment bar | How far through a long linear form | Registration (6 segments), CRS calculator |
| Dot rail | How many short steps remain | Quick onboarding (4 dots) |
| Numbered stepper | Which named step, and can I go back | CRS calculator, BC PNP eligibility |
| Meter | A score against its maximum | CRS, PNP, profile strength |
| Ring | Completeness of one thing | Profile strength only — never a score |
| Timeline | What the system is doing right now | AI assistant processing |

Specs: track height 8 px, radius 999px, Grey 200 track. Segment bar 5 px. Stepper circles 24 px with
11.5/700 numerals. Ring 7 px stroke, ink on Grey 200.

**The processing timeline** is what the AI assistant shows instead of a spinner. It names the actual
work being done, one line at a time — "Reading your profile", "Checking latest IRCC requirements",
"Analyzing eligibility", "Generating personalized answer" — which is what makes a four-second wait
feel like diligence rather than lag. Each row resolves in order; the pending row is a hollow ring in
Grey 300.

---

## 14. Navigation

Five destinations, fixed for the life of the app: **Home, Jobs, Immigration, Settlement, Profile**.
Everything else is reached from inside one of those.

| Pattern | Rule |
|---|---|
| App bar | Back chevron left, title centred at 16 px / 800, at most two trailing icons. On the home screen the title is replaced by the wordmark. |
| Tabs | Scrollable, no more than five. Active is Settle Red with a 2.5 px underline; the underline is the only indicator — no pill, no fill. |
| Bottom nav | Fixed five. Active icon and label both go Settle Red; inactive is Grey 500. Labels never hide. |
| List row | Optional leading tile or flag, title + supporting line, optional verdict pill, chevron last. The chevron means the row opens a screen; a row without one is not tappable. |

---

## 15. Conversation

The AI assistant is a full surface of its own, and the only place in the product where a bubble
inverts against the screen it sits on. The user's words are ink; the assistant's are on the neutral
ground — **the assistant never speaks in brand red**. Both roles hold in dark, where the user's bubble
becomes near-white with dark text.

| Element | Spec |
|---|---|
| User bubble | Ink fill (Grey 900), surface-coloured text, radius 16 / 16 / 4 / 16, right-aligned, max 78% width |
| Assistant bubble | Neutral fill (Grey 100), ink text (Grey 900), radius 16 / 16 / 16 / 4, left-aligned |
| Typing | Three 7 px Grey 400 dots, 1.2 s stagger. Replaced by the timeline for anything over ~2 s. |
| Suggested question | Full-width row, 12 px radius, 600 weight, trailing chevron. Six to eight on the empty state. |
| Composer | Attach glyph, Grey 100 pill input, 44 px red circular send |
| Presence | 7 px ink dot + "Online · Based on Your Profile" at 11.5/600 |
| Voice mode | Inverts the screen to Grey 950. Waveform in Settle Red, record button 72 px. The only dark screen after onboarding. |

Answers that carry a score or an eligibility verdict render it as a **real score card inside the
bubble**, not as text — so "468, Good Range" looks the same in chat as it does on the dashboard.

---

## 16. Comparison

Two comparison surfaces: the plan matrix on the paywall and the score breakdown on a CRS result. Both
tint the column being sold or summed rather than drawing vertical rules.

- **Plan matrix** — feature rows down the left, one tinted column per tier (`#FDF4F4` for Pro,
  `#F6F6F6` for Pro+). Included is a red tick; free is the word "Free"; not included is an em dash.
- **Score breakdown** — label/value rows on a `#F7F7F7` card, values right-aligned and tabular, a
  Grey 200 rule above the total, and the total in Settle Red.

A dash — not a cross, not a red X — marks a feature a tier does not include. **Absence is neutral
information; the product never punishes the cheaper choice visually.**

---

## 17. Feedback & milestones

Three moments get a full screen to themselves: account created, eligibility confirmed, and
subscription activated. Each is a centred glyph in a tinted ring, a headline, one or two sentences,
and a single forward action.

**A red ring marks a step completed; a solid ink circle marks a transaction settled.** That is the
whole rule — account creation and profile milestones get the open red ring, money and eligibility
outcomes get the filled ink disc with a white check. Open versus filled is the signal, not hue.

Confetti (scattered maple leaves and dots at 6–10 px) appears on these three screens only, and
respects reduced motion.

---

## 18. Composed screen

The dashboard, assembled entirely from the components above — no bespoke parts. If a screen cannot be
built from this inventory, either the screen is wrong or the system is missing something; both are
worth stopping for.

| Element | What it is |
|---|---|
| App bar | Wordmark variant, notification icon |
| Ring | Profile strength — the only ring in the product |
| Card | Hairline border, 16 px radius, no shadow |
| Hub tiles | Module tint fill, surface-coloured glyph plate |
| Primary button | Full width, trailing arrow |
| Bottom nav | Five fixed destinations, Home active |

---

## 19. Patterns

Four flows account for every screen in the deck. Each has a shape, and new features should be fitted
into one rather than inventing a fifth.

### A — Progressive onboarding

**Welcome → Create account → Basic info → Contact → Profile type → Goals → Review → Success.**

One decision per screen, a segment bar throughout, a full-width primary at the bottom, and a review
screen before anything is committed. Every field entered is echoed back on the review screen with an
inline **Edit** link — the user never has to go back through the flow to change one answer.

### B — Assess, then disclose

**Tool overview → numbered steps → result → breakdown → what to do next.**

Used by the CRS calculator, every PNP calculator and the eligibility checker. The result screen always
carries three things in this order: the number, the verdict pill, and the sentence that puts it in
context ("You are in a competitive range for Express Entry"). The breakdown is one tap away, never on
the result screen itself. Every result closes with the provisional disclaimer — final eligibility is
determined by the Government of Canada, and the screen says so.

### C — Conversational assistance

**Empty state with suggestions → question → processing timeline → structured answer → related
questions → save.**

The assistant never ends on a full stop: every answer is followed by two to five next actions drawn
from the modules, so the conversation routes back into the product. A thread can be saved to the
profile and exported as a PDF summary.

### D — Value, then payment

**Locked feature → plans → comparison → payment → activated.**

The paywall is only ever reached by trying to use a premium feature — it is not a screen in the
navigation. It states what stays free ("Basic profile and job search are always free") before it
states the price, and the plan card shows what is included before the payment form appears.

| Pattern | Screens in the deck | Progress device | Ends with |
|---|---|---|---|
| A — Onboarding | Board 3 (1–3), Board 4 (1–8) | Segment bar | Full-screen success, red ring |
| B — Assess & disclose | Board 2, Board 6 (1–12) | Numbered stepper | Score + verdict pill + context line |
| C — Conversation | Board 5 (1–10) | Processing timeline | Related questions + save |
| D — Value & payment | Board 7 (1–5) | None | Full-screen success, ink circle |

---

## 20. Voice & content

The reader may be reading English as a third language, on a phone, about something that determines
where they live. Write plainly, in the second person, and never overstate what the product knows.

**Do**

- Address the reader as **you**, and the product as **WorkSettle** — never "we" for the AI.
- Give a number its context in the same breath: **468 — competitive for recent draws**.
- Say what a control does before you say it is premium.
- Name the province, the program and the stream in full on first use, then abbreviate.
- Keep screen titles under six words and sentence-case the supporting line.

**Don't**

- Don't promise an outcome — results are initial, and IRCC decides.
- Don't use red to report a problem; red is brand and action only.
- Don't use immigration jargon without expanding it once (CRS, ECA, NOC, CLB).
- Don't stack two primary buttons, or centre body copy outside the three success screens.
- Don't introduce a second accent hue — no green, amber, blue, purple or teal enters this system.
- Don't let a module tile or a state chip fill a button or a page background.

| Instead of | Write | Why |
|---|---|---|
| "Invalid input" | "Enter your date of birth as YYYY-MM-DD" | Names the fix, not the failure |
| "You are ineligible" | "You may qualify once you have a valid language test" | Points at the gap that closes |
| "Submit" | "Create Account" | The label says what happens |
| "Your CRS is 468" | "468 — competitive for recent draws of 435–470" | A number alone is not an answer |
| "Error 402" | "That card was declined. Try another card or use PayPal." | Gives the person a next move |

**Never state an immigration outcome as certain.** Assessments are "based on the information you
provided" and results are initial — final eligibility rests with IRCC or the province. This is a legal
requirement and a trust requirement, and it belongs in the component: the result card carries the
disclaimer slot so no screen can forget it.

---

## 21. Accessibility

Measured contrast ratios for the pairs the product actually uses.

### Light theme

| Pair | Ratio | Passes | Use for |
|---|---|---|---|
| `#111111` on `#FFFFFF` | 18.88:1 | AAA | All headings and primary text |
| `#525252` on `#FFFFFF` | 7.81:1 | AAA | Body copy on cards |
| `#757575` on `#FFFFFF` | 4.61:1 | AA | Supporting lines, captions |
| `#FFFFFF` on `#E4101B` | 4.78:1 | AA | Primary button labels |
| `#B00A13` on `#FFFFFF` | 7.24:1 | AAA | Red text at body size — use 700, not the base red |
| `#FFFFFF` on `#111111` | 18.88:1 | AAA | Filled state chip — label on the ink fill |
| `#3D3D3D` on `#FFFFFF` | 10.86:1 | AAA | Outlined state chip — label |
| `#525252` on `#F4F4F4` | 7.10:1 | AAA | Tinted state chip — label |
| `#111111` on `#F4F4F4` | 17.17:1 | AAA | Module glyph on its tile — one pair for all seven |
| `#A3A3A3` on `#FFFFFF` | 2.52:1 | Fails | Placeholders and decorative icons only — never real content |

### Dark theme

| Pair | Ratio | Passes | Use for |
|---|---|---|---|
| `#F5F5F5` on `#141414` | 16.90:1 | AAA | Headings and primary text on a card |
| `#E0E0E0` on `#141414` | 13.96:1 | AAA | Field labels |
| `#B5B5B5` on `#141414` | 8.98:1 | AAA | Body copy on cards |
| `#969696` on `#141414` | 6.23:1 | AA | Supporting lines, captions |
| `#FFFFFF` on `#E4101B` | 4.78:1 | AA | Primary button labels — the fill is unchanged in dark |
| `#EE6A6F` on `#141414` | 6.08:1 | AA | Red as text, border or icon |
| `#141414` on `#F5F5F5` | 16.90:1 | AAA | Filled state chip — label on the ink fill |
| `#CACACA` on `#141414` | 11.24:1 | AAA | Outlined state chip — label |
| `#E0E0E0` on `#1C1C1C` | 12.91:1 | AAA | Tinted state chip — label |
| `#F5F5F5` on `#1C1C1C` | 15.63:1 | AAA | Module glyph on its tile — one pair for all seven |
| `#707070` on `#141414` | 3.72:1 | AA (non-text) | Placeholders and decorative icons only |

Module tiles are one pair rather than seven: ink `#111111` on `#F4F4F4` measures **17.17:1** in light,
and `#F5F5F5` on `#1C1C1C` measures **15.63:1** in dark. Collapsing the spectrum removed the six
weakest contrast pairs in the system — the old CRS purple cleared AA on its tint by 6.10:1, the new
tile clears it by nearly three times that.

**This edition passes a greyscale test the full system could not.** With hue removed as a channel, no
information in the product depends on colour vision at all; the only remaining colour signal is the
red on filled actions, which is always redundant with a label.

The hairline is the one pair that is deliberately low. `#2A2A2A` on a `#141414` card measures 1.28:1
— which is very slightly *stronger* than the light theme's own hairline (`#E6E6E6` on white, 1.25:1).
A card separating from its ground is 1.07:1 in dark and 1.04:1 in light. Both themes ask the border,
not the fill, to draw the boundary, and both keep it quiet on purpose.

**Do**

- 48 px minimum touch target on every control, including the chevron rows.
- Pair every verdict color with its word — the pill always carries text, never color alone.
- Label every icon-only control (send, notifications, settings) for screen readers.
- Keep the 2 px red focus ring; it is the only focus style in the system.
- Support 200% text scaling — cards grow, they do not clip.

**Don't**

- Don't set body copy in Grey 400; it fails at 2.52:1 on white.
- Don't set paragraph text in the base red — use Red 700 on light, `#EE6A6F` on dark.
- Don't animate the confetti or the typing dots for readers who have asked for reduced motion.
- Don't rely on the progress bar alone to report a verdict.
- Don't place text over the CN Tower photography without a scrim, in either theme.

---

## 22. Screen inventory

Every screen in the seven-board deck, and the components each one introduced. This is the audit trail:
if a component in this document has no screen against it, it is not in the system.

| Board | Screens | Introduced |
|---|---|---|
| 1 | Feature ecosystem — the seven modules around a central profile, on a dark Toronto skyline ground | Module marks, dark hero treatment, journey rail (WORK · IMMIGRATE · SETTLE), positioning lockup |
| 2 | Profile dashboard and Immigration tab — profile header, score grid, quick actions; pathway list with PNP streams | Score card, verdict pills, meters, tabs, quick-action tiles, bottom nav, banner, province rows |
| 3 | Onboarding (Welcome, Quick Onboarding, Account Created, Feature Hub) and the seven module detail screens | Dot rail, full-screen success, hub grid, module screen header (60 px circle), benefit checklist, module preview cards |
| 4 | Registration — Welcome, Create Account, Basic Info, Contact, Profile Type, Goals, Almost There, Dashboard | Segment bar, social sign-in rows, labelled fields with leading icons, phone field, selection cards, checkbox list, review summary with inline Edit |
| 5 | AI Assistant — entry, welcome, suggested questions, processing, answer, related topics, voice mode, voice answer, follow-ups, save | Chat bubbles, typing dots, suggestion rows, processing timeline, composer, presence dot, voice mode (dark), answer-embedded score card |
| 6 | Immigration and CRS — dashboard, hub, calculator overview, five calculator steps, PNP list, BC PNP, stream results, other programs, compare | Numbered stepper, numbered step list, selects and radios, score breakdown table, result screen, flag frames, match badges, compare checkboxes |
| 7 | Subscription — upgrade prompt, plan selection, feature comparison, payment, success | Lock state, monthly/yearly toggle with savings pill, plan cards, Most Popular badge, comparison matrix, payment method radios, ink success |

---

## 23. Provenance

How the values in this document were arrived at, so that anything here can be challenged against the source.

| Value | Method | Observed | Adopted |
|---|---|---|---|
| Primary red | Weighted centroid of the longest solid horizontal runs in filled CTA buttons across all 7 boards | `#DA191C` → `#F30618` | `#E4101B` |
| Logo red | Read directly from the client-supplied vector file, not sampled — this one is exact | `#b80404` | `#b80404`, logo only |
| Neutral ramp | Mode of low-saturation pixels on the five light boards; heading ink and body grey sampled from glyph cores | `#757575`, `#8A8A8A`, `#E0E0E0` | Desaturated to true neutral, 12 steps |
| Dark surface | Chat bubble and voice-mode fills | `#050505` | `#111111` / `#000000` |
| Success | Progress fills and success circles, boards 2 and 7 | `#01CD8E`, `#00C689` | Retired — success is now a solid ink chip |
| Module hues | Longest saturated run per hue band, boards 1 and 3 | `#009688`, `#6B44D0`, `#F97C03`, `#00A5BD`, `#E3114E` | Retired — modules are ink, identified by glyph |
| Tint steps | Rose and tinted card backgrounds | `#FDF4F4`, `#FDF4F4`, `#F7F7F7` | Role ramp step 100 |
| Ramps | Generated in OKLCH on one shared lightness scale, chroma tapered at the extremes, then contrast-checked | — | 9 steps per role |

### Two honest caveats

The source boards are **rendered mockups, not production files**, so exact pixel values carry JPEG
noise — the red spanned a visible range across boards and has been unified here.

The typeface in the mockups is a **system face, not a licensed brand font**. Plus Jakarta Sans is a
close, freely licensable match and is a recommendation to confirm, not a measurement.

### Not yet defined

These need a decision before build:

- Empty and error states for the job and appointment lists
- Skeleton loading
- Tablet and web breakpoints
- French localisation of the fixed verdict pills
- The document-upload component implied by the Documents tab

---
