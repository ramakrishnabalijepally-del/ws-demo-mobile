# WorkSettle Mobile — Plan

**Status:** approved scope, not yet built · **Written:** 2026-09-08
**Companion:** [`IMPLEMENTATION.md`](./IMPLEMENTATION.md) — the ordered build sequence

---

## 1. What we are building

A **Flutter (Dart) mobile UI/UX for the candidate role only**, driven entirely by
**mock data**. No backend, no auth, no storage, no networking. Every screen is
navigable and every state is reachable, but nothing leaves the device.

Roles other than the candidate (employer, RCIC consultant, admin) are **out of
scope** and no shell, route or model for them is created.

### The two sources, and which wins

| Source | Role |
| --- | --- |
| **`design/worksettle-design-system.md`** | **PRIMARY.** Every colour, type step, radius, spacing value, component spec, state ladder, copy rule and accessibility pair. If anything anywhere disagrees with this file, this file wins. |
| **`Screenshots/` (61 images)** | **FEATURE INVENTORY ONLY.** They say *what screens and flows exist*. They do **not** say what anything looks like. |

The screenshots come from two different sources — a blue job-portal template
("Gawean") and an older red WorkSettle deck. **Neither palette is used.** Every
blue in those images becomes ink or Settle Red per the design system; every
green/amber/red status pill becomes the filled/outlined/tinted ladder.

---

## 2. Rule conflicts, resolved in favour of the design system

The `.agents/rules/` files were written before the design system arrived. These
rules are **wrong** and get changed as step one of implementation.

| Rule file | Said | Design system says | Action |
| --- | --- | --- | --- |
| `08-design.md` | Seven-colour feature accent system (red, blue, green, purple, cyan, amber, pink) | **Spectrum retired.** All modules are ink `#111111` on Grey 100 `#F4F4F4`, identified by glyph. Job Matching alone keeps Settle Red. | Rewrite §Colour, §Module marks |
| `08-design.md` | "CTAs stay rounded rectangles, **not pills**" | "**Every button is a full pill**" (999 px) | Reverse |
| `08-design.md` | Status colours: green Eligible, blue High Potential, amber Potential | **No hue.** Filled (ink) → outlined (grey border) → tinted (Grey 100) ladder, every chip carries a mandatory glyph | Rewrite §Status |
| `08-design.md` | `--primary` ≈ `#E11B22` [measured, unconfirmed] | **`#E4101B`** exact, plus a 10-step red ramp | Replace with exact values |
| `08-design.md` | Logo colour unresolved | Logo is `#b80404`, **logo file only**, never elsewhere; reversed logo lightens to `#EF4444` | Add |
| `03-styling.md` r5 | "**Light-only.** Do not supply a `darkTheme`" | Dark is a **full second theme**, with a complete inverted ramp and its own contrast table. The Appearance screen has a Dark Mode toggle. | Reverse — build both themes |
| `01-stack.md` | Typeface unconfirmed, custom font needs approval | **Plus Jakarta Sans**, 8 named type roles with exact size/weight/tracking | Adopt; bundle the font |
| `01-stack.md` | Icons: one set, Material default | Two styles: **solid** for module tiles + bottom nav, **1.9 px stroked** for fields and rows | Adopt as Material filled + outlined |
| `02-structure.md` | Features are flat | (silent) | Extend with a **sub-feature** layer — see §5 |

Everything else in `.agents/rules/` stands.

---

## 3. Information architecture

The design system fixes **five destinations for the life of the app**:
**Home · Jobs · Immigration · Settlement · Profile** (§14). The screenshots show
a 4-tab template nav (Home / Applications / Chat / Profile) — that is discarded.
Applications, Saved Jobs and recruiter chat become **sub-features of Jobs**.

```
┌─ Outside the shell (no bottom nav) ────────────────────────────┐
│  Splash → Onboarding (3, dot rail) → Sign In / Sign Up /       │
│  Forgot Password → Registration (7 steps, segment bar)         │
│  AI Assistant (full surface, voice mode inverts to #000)       │
│  Paywall (modal, reached only by touching a locked feature)    │
└────────────────────────────────────────────────────────────────┘
┌─ StatefulShellRoute — 5 tabs, each keeps its own stack ────────┐
│  Home        dashboard · hub grid · notifications · tips       │
│  Jobs        search · details · apply · applications · saved   │
│              · recruiter chat                                   │
│  Immigration CRS · PNP · eligibility · programs · compare      │
│  Settlement  checklist · appointments · resources              │
│  Profile     profile · documents · goals · settings · help     │
└────────────────────────────────────────────────────────────────┘
```

### The seven modules (design system §3)

They appear as the Home hub grid and each has a screen. All ink-on-Grey-100
except Job Matching.

| Module | Lives under | Base / tint |
| --- | --- | --- |
| Job Matching | Jobs | `#E4101B` / `#FBE7E8` |
| Profile Matching | Profile | `#111111` / `#F4F4F4` |
| Immigration Eligibility | Immigration | `#111111` / `#F4F4F4` |
| CRS Predictor | Immigration | `#111111` / `#F4F4F4` |
| AI Voice & Chat | full-screen route | `#111111` / `#F4F4F4` |
| Smart Checklist | Settlement | `#111111` / `#F4F4F4` |
| Appointments | Settlement | `#111111` / `#F4F4F4` |

---

## 4. Screen inventory — 61 screenshots → 84 screens

Every screenshot is accounted for. Screens marked **[DS]** are required by the
design system but have no screenshot; they are built from the spec.

### A · Launch & onboarding — 4 screens
| # | Screen | Source |
|---|---|---|
| A1 | Splash — wordmark over a faded photo | 220805 |
| A2 | Onboarding 1 — "Find Your **Dream** Job" | 220821 |
| A3 | Onboarding 2 — "Match Jobs Based On Your **Profile**" | 221037 |
| A4 | Onboarding 3 — "We Are Here To Help You **Achieve Your** Dreams!" | 221044 |

Dot rail (4 dots, §13). Red word emphasis per §4 — part of a headline in red.

### B · Authentication — 7 screens
| # | Screen | Source |
|---|---|---|
| B1 | Sign In — rest | 221053 |
| B2 | Sign In — email error "Enter a valid email address" | 221101 |
| B3 | Sign In — password error | 221109 |
| B4 | Sign Up — name, phone, password, confirm | 221120 |
| B5 | Forgot Password — email entry | 221128 |
| B6 | Forgot Password — choose SMS or email (selection cards) | 221151 |
| B7 | Account created — full-screen success, **open red ring** [DS] | §17 |

Error copy is rewritten per §20: never "Invalid email".

### C · Registration flow — 8 screens (design system Pattern A)
| # | Screen | Source |
|---|---|---|
| C1 | Welcome / Let's Get You Started | [DS] |
| C2 | Basic Information | [DS] |
| C3 | Contact Information — phone field with flag + dial code | [DS] |
| C4 | Profile Type — Job Seeker / Student / Other (selection cards) | [DS] |
| C5 | Your Goals — multi-select checkbox list | [DS] |
| C6 | Job categories — "What job you want?", pick 3–5 | 221423 |
| C7 | Almost There — review with inline **Edit** per row | [DS] |
| C8 | Profile photo + details | 221430, 221437 |

Segment bar across the top throughout (6 segments, §13).

### D · Home — 6 screens
| # | Screen | Source |
|---|---|---|
| D1 | Dashboard — wordmark bar, greeting, **profile-strength ring**, hub grid, job preview | 221443 + §18 |
| D2 | Notifications | 221450 |
| D3 | Tips for you — list | 221458 |
| D4 | Tip article | 221504 |
| D5 | Feature hub — all seven modules, 2-up | §3 |
| D6 | Module preview / detail shell | §3 |

The ring is the **only ring in the product** and reports completeness, never a
score (§13).

### E · Jobs — 8 screens
| # | Screen | Source |
|---|---|---|
| E1 | Job Recommendation — category chips + cards | 221541 |
| E2 | Search Jobs — typing, "489 found" | 221548 |
| E3 | Search filter sheet — field / salary / type / location | 221558 |
| E4 | Field of work — full chip screen | 221605 |
| E5 | Search results | 221612 |
| E6 | Not found — empty state | 221622 |
| E7 | Job Details — salary, type, location, requirements | 221712, 221719 |
| E8 | Share sheet | 221728 |

Salary/type/location values are **ink**, not the template's blue.

### F · Apply flow — 6 screens
| # | Screen | Source |
|---|---|---|
| F1 | Upload Resume/CV — empty | 221736 |
| F2 | Uploading | 221745 |
| F3 | Upload failed | 221754 |
| F4 | Uploaded — PDF row + Apply | 221805 |
| F5 | Application successful — **filled ink disc** | 221817 |
| F6 | Application failed | 221826 |

§17: money and outcome moments get the filled ink disc, not a red ring.

### G · Applications — 5 screens
| # | Screen | Source |
|---|---|---|
| G1 | Applications list — All / Accepted / Interview / Rejected | 221945 |
| G2 | Detail — Pending → **tinted** chip | 221953 |
| G3 | Detail — Rejected → **outlined** chip + letter | 222000 |
| G4 | Detail — Interview scheduled → outlined chip + Join Interview | 222006 |
| G5 | Detail — Accepted → **filled** chip + message recruiter | 222012 |

The four statuses map onto the three-rung ladder; **red is never a state
colour** (§2), so "Rejected" is outlined-neutral with a full sentence, not red.

### H · Saved jobs — 2 screens
| # | Screen | Source |
|---|---|---|
| H1 | Saved Jobs | 222018 |
| H2 | Remove bookmark — confirm sheet | 222026 |

### I · Recruiter chat & calls — 7 screens
| # | Screen | Source |
|---|---|---|
| I1 | Chat list — All / Unread / Archived | 222106 |
| I2 | Swipe-to-archive | 222114 |
| I3 | Archive confirm sheet | 222122 |
| I4 | Thread — composing | 222131 |
| I5 | Thread — with Join Interview action | 222321 |
| I6 | Call connecting | 222328 |
| I7 | Call active — timer | 222336 |

Bubble spec from §15: user = ink fill, recruiter = Grey 100. Same shell as the
AI assistant, different data.

### J · Immigration — 14 screens (Pattern B)
| # | Screen | Source |
|---|---|---|
| J1 | Immigration hub — CRS, PNP, Other Programs, Compare | 222707 (features), §19 |
| J2 | CRS overview | [DS] |
| J3–J7 | CRS steps 1–5 — numbered stepper | [DS] |
| J8 | CRS result — metric, verdict pill, context line | [DS] |
| J9 | CRS breakdown — `#F7F7F7` table, total in Settle Red | §16 |
| J10 | PNP province list — flag frames, 40 px, Grey 200 hairline | 222713 |
| J11 | Province streams | [DS] |
| J12 | Stream eligibility questions | [DS] |
| J13 | Stream results — match badges | [DS] |
| J14 | Compare options — checkboxes | §16 |

Every result closes with the provisional-disclaimer slot (§20) — a component
requirement, not per-screen copy.

### K · Settlement — 6 screens
| # | Screen | Source |
|---|---|---|
| K1 | Settlement hub | [DS] |
| K2 | Smart Checklist | §3 |
| K3 | Appointments — consultation types with durations | 222721 |
| K4 | Appointment detail / booking | 222721 |
| K5 | Booking confirmed | [DS] |
| K6 | Resources — French classes (Pro+ locked) | 221412 |

### L · AI Assistant — 8 screens (Pattern C)
| # | Screen | Source |
|---|---|---|
| L1 | Empty state — 6–8 suggested questions | §15 |
| L2 | Thread with typing dots | §15 |
| L3 | **Processing timeline** — named steps, not a spinner | §13 |
| L4 | Structured answer — score card embedded in the bubble | §15 |
| L5 | Related questions | §19 |
| L6 | Voice mode — **Grey 950 ground**, red waveform, 72 px record | §15 |
| L7 | Voice answer | §15 |
| L8 | Saved conversations | §19 |

### M · Profile — 8 screens
| # | Screen | Source |
|---|---|---|
| M1 | Profile — avatar, verified tick, fields | 222421 |
| M2 | Change avatar sheet | 222429 |
| M3–M7 | Tabs: Overview · Immigration · Jobs · Documents · Goals | §22 board 2 |
| M8 | Document upload | §23 "not yet defined" — built minimally, flagged |

### N · Settings & help — 8 screens
| # | Screen | Source |
|---|---|---|
| N1 | Settings — Notification, Security, Appearance, Help, Logout | 223006 |
| N2 | Notification toggles | 223015 |
| N3 | Security toggles | 223027 |
| N4 | **Appearance — Dark Mode toggle (drives the real theme)** | 223034 |
| N5 | Help | 223044 |
| N6 | FAQ — accordion + category chips | 223052 |
| N7 | Terms and Conditions | 223059 |
| N8 | Privacy Policy | 223108 |
| N9 | Logout confirm sheet | 223146 |

FAQ copy says "Gawean" in the template — rewritten to WorkSettle.

### O · Subscription — 5 screens (Pattern D)
| # | Screen | Source |
|---|---|---|
| O1 | Locked feature prompt | §19 |
| O2 | Plans — monthly/yearly toggle, Save 17% pill | §11 |
| O3 | Comparison matrix — Pro `#FDF4F4`, Pro+ `#F6F6F6`, em dash for absent | §16 |
| O4 | Payment method — radio selection cards | §22 board 7 |
| O5 | Activated — **filled ink disc** + confetti | §17 |

**Total: 84 screens** across 15 groups.

---

## 5. Folder structure — features and sub-features

Extends `.agents/rules/02-structure.md` with a **sub-feature layer**, because
`jobs` alone carries six distinct flows.

```
lib/
├─ app/
│  ├─ theme/          colors · typography · spacing · radii · elevation · motion
│  │                  ws_colors (ThemeExtension) · ws_theme
│  ├─ router/         routes · shell scaffold · transitions
│  ├─ app.dart
│  └─ providers.dart  theme mode, mock session
│
├─ shared/
│  ├─ widgets/        WsButton WsCard WsChip WsIconTile WsListRow WsField
│  │                  WsSegmentBar WsDotRail WsStepper WsMeter WsRing
│  │                  WsScoreCard WsBanner WsPlanCard WsWordmark WsSuccess
│  ├─ models/         verdict · money · module
│  ├─ utils/
│  └─ shared.dart
│
├─ features/
│  ├─ onboarding/     splash · slides
│  ├─ auth/           sign_in · sign_up · forgot_password
│  ├─ registration/   basic_info · contact · profile_type · goals ·
│  │                  job_categories · review
│  ├─ home/           dashboard · notifications · tips · hub
│  ├─ jobs/           search · details · apply · applications · saved · chat
│  ├─ immigration/    hub · crs · pnp · eligibility · programs · compare
│  ├─ settlement/     hub · checklist · appointments · resources
│  ├─ assistant/      chat · voice · saved
│  ├─ profile/        overview · documents · goals · settings · help
│  └─ subscription/   plans · comparison · payment
│
└─ main.dart
```

**Sub-feature rule.** A sub-feature is a folder inside a feature holding its own
`presentation/`, `controllers/`, `data/`, `models/`. It has **no barrel** — only
the parent feature exports. Sub-features may import their siblings' internals
within the same feature; across features, the barrel rule still holds.

---

## 6. Design tokens — the exact build

Straight from `design/worksettle-design-system.md`. No estimation anywhere.

**Red ramp** — 100 `#FBE7E8` · 200 `#F5CDCF` · 300 `#EDA3A6` · 400 `#EE6A6F` ·
500 `#F0353C` · **Settle Red `#E4101B`** · 600 `#F0272E` · 700 `#B00A13` ·
800 `#7E060D` · 900 `#4A0308`. Logo red `#b80404` is **inside the logo file
only** and never becomes a token.

**Grey ramp, true neutral (zero saturation)** — 0 `#FFFFFF` · 50 `#FAFAFA` ·
100 `#F4F4F4` · 200 `#E6E6E6` · 300 `#D1D1D1` · 400 `#A3A3A3` · 500 `#757575` ·
600 `#525252` · 700 `#3D3D3D` · 800 `#262626` · 900 `#111111` · 950 `#000000`.

**Type** — Plus Jakarta Sans. display 28/34/800/−0.03em · title-lg 22/28/800 ·
title 17/23/700 · metric 26/30/800 tabular · body 15/23/500 · label 13/18/700 ·
caption 12/17/500 · overline 10/12/700/+0.12em.

**Space** — 4 8 12 16 20 24 32 48. Gutter 20, card padding 16, card gap 12.

**Radius** — pill 999 (anything you press) · card 16 · row 14 · field 12 ·
tile-sm 10 · checkbox 6. *The radius encodes what the thing is.*

**Elevation** — border-only `1px #E6E6E6` is the default and the boundary;
raised 2–3/1/5%; floating 14/4/9%; modal 40/18/18% over a 40% scrim. The primary
button alone carries a **red shadow** (8 blur, 2 down, Settle Red 28%), dropped
on press.

**Dark** — ground `#0A0A0A` · card `#141414` · neutral `#1C1C1C` · hairline
`#2A2A2A` · body `#B5B5B5` · heading `#F5F5F5`. **Settle Red does not change
where it fills a shape**; red as text/border/icon lightens to `#EE6A6F`.

---

## 7. Mock data

One fixture library per feature under `<feature>/data/mock/`, typed, `const`
where possible, reached through a repository so the real API is a one-file swap
(`.agents/rules/02-structure.md`).

The candidate is **Adam Smith** throughout (from the screenshots), a UI/UX
designer newcomer to Canada:

| Set | Contents |
| --- | --- |
| Candidate profile | Adam Smith · adam.smith@yourdomain.com · b. 1995-12-27 · UI/UX Designer · profile strength **72%** |
| Jobs | ~24 postings — real Canadian employers, salary in CAD, permit-friendly flags, NOC codes |
| Applications | 5 covering all four states |
| Saved jobs | 7 |
| Chat threads | 5 recruiter threads, one with an interview invitation |
| Notifications | 6 |
| Tips | 3 articles with body copy |
| CRS | inputs + result **468 / 1200**, "Good Range", recent draws 435–470, 9-row breakdown |
| PNP | 6 provinces (AB, BC, ON, NS, QC, YT, SK) with 3–5 streams each |
| Checklist | 12 settlement steps across 4 phases |
| Appointments | 7 consultation types with durations and prices |
| Assistant | 8 suggested questions, 4 scripted Q&A with timeline steps and an embedded score card |
| Plans | Free · Pro $10/mo · Pro+ $50/mo, yearly saves 17%, 14-row comparison |

Every number in the fixtures is one the design system already names, so the
screens match the spec rather than inventing figures.

---

## 8. Assumptions — flagged, not blocking

1. **Bottom nav is five tabs, not the screenshots' four.** The design system
   fixes them "for the life of the app". Applications, Saved and recruiter chat
   move under Jobs.
2. **The template blues are discarded entirely** — `#3B82F6`, the blue Continue
   buttons, blue prices, blue nav. All become ink or Settle Red.
3. **"Rejected" is not red.** §2 forbids red as a state colour. It renders as an
   outlined chip plus the explanatory letter.
4. **The wordmark is not shipped.** `worksettle.svg` / `worksettle-reverse.svg`
   are named in §1 but were not supplied. `WsWordmark` renders the asset when
   present and a clearly-marked text placeholder until then — **the logo is
   never redrawn** (§1).
5. **Plus Jakarta Sans must be added to `assets/fonts/`.** It is not bundled
   here. Without it the app falls back to the platform sans and the type is
   *approximately* right and *exactly* wrong. Flagged as a blocker for visual
   sign-off, not for the build.
6. **Photography is absent** — splash, onboarding, tips and the CN Tower hero
   need images. Built with tokened placeholder surfaces carrying a
   `// TODO(assets):`.
7. **Province flags** are the one full-colour imagery allowed (§7). Not
   supplied; placeholder frames with the correct 40 px / 10 px / Grey 200
   treatment.
8. **French classes, video calls and document upload** appear in the screenshots
   but §23 lists document upload as "not yet defined". Built minimally, marked
   `// TODO(backend):`.

---

## 9. Known constraint — no Flutter toolchain here

`flutter` and `dart` are **not installed** on this machine or in the WSL
distribution. Consequences:

- Every file will be written correctly by hand, following the SDK's APIs.
- **`flutter analyze`, `dart format` and `flutter test` cannot be run**, so the
  verification gate in `.agents/rules/06-quality-and-verification.md` cannot be
  completed by me. I will not claim it passed.
- `flutter create` cannot generate the `android/` and `ios/` runner folders, so
  the repo will contain `lib/`, `pubspec.yaml`, `analysis_options.yaml`,
  `assets/` and `test/` — everything except the native shells.

**To run it**, install Flutter, then from the repo root:

```bash
flutter create . --project-name worksettle_mobile --platforms=android,ios
flutter pub get
dart format lib test
flutter analyze
flutter run
```

`flutter create .` fills in the native folders **without touching existing
`lib/` files**. Expect the first `flutter analyze` to surface typos that no
amount of care substitutes for a compiler — those get fixed in one pass.

---

## 10. Phases

Detail, file lists and per-phase checklists live in
[`IMPLEMENTATION.md`](./IMPLEMENTATION.md).

| # | Phase | Delivers |
|---|---|---|
| 0 | Rules reconciliation | `.agents/rules/` updated to match the design system |
| 1 | Project skeleton | pubspec, analysis_options, main, app shell |
| 2 | Design system | theme, tokens, `WsColors`, both brightnesses |
| 3 | Shared widgets | the ~18 components of design system §8–§17 |
| 4 | Router + shell | `StatefulShellRoute`, five tabs, transitions |
| 5 | Launch, auth, registration | groups A · B · C — 19 screens |
| 6 | Home | group D — 6 screens |
| 7 | Jobs | groups E · F — 14 screens |
| 8 | Applications, saved, chat | groups G · H · I — 14 screens |
| 9 | Immigration | group J — 14 screens |
| 10 | Settlement | group K — 6 screens |
| 11 | AI assistant | group L — 8 screens |
| 12 | Profile, settings, help | groups M · N — 17 screens |
| 13 | Subscription | group O — 5 screens |
| 14 | Polish | dark audit, 200% text scale, 48 dp targets, reduced motion |

---

## 11. Definition of done

- All 84 screens reachable from a cold start with no dead ends.
- Zero colour literals outside `lib/app/theme/`; zero hand-rolled `TextStyle`.
- Light **and** dark correct on every screen, toggled from Appearance.
- Every state chip carries its glyph — a chip without one is a bug (§2).
- No screen overflows at 360 dp; nothing clips at 200% text scale.
- Every touch target ≥ 48 dp.
- Confetti and typing dots honour reduced motion.
- Every non-functional control marked `// TODO(backend):` and listed in the
  summary.
- The verification gate reported honestly, including that I could not run it.
