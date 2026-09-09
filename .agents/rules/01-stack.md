---
trigger: always_on
---

# The stack — locked, non-negotiable

| Concern | The one allowed choice | Notes |
| --- | --- | --- |
| Framework | **Flutter** (stable channel) | targets iOS + Android |
| Language | **Dart 3**, sound null safety | no `dynamic` as a shortcut |
| Design system | **Material 3** (`useMaterial3: true`) | restyled to the WorkSettle brand |
| Theming | **`ThemeData` + `ColorScheme` + `ThemeExtension`** | tokens in `lib/app/theme/` |
| Routing | **`go_router`** | declarative routes in `lib/app/router/` |
| State | **`flutter_riverpod`** | the only state/DI solution |
| Animation | **Flutter's own framework** | see `04-animation.md` |
| Networking | none while mocked | add `http` only when a backend exists |
| Typeface | **Plus Jakarta Sans**, bundled | see below |
| Icons | **Material Icons**, filled + outlined | never mix a third set |
| Lints | **`flutter_lints`** via `analysis_options.yaml` | must pass clean |

Widgets are **composed, not configured by a CSS-like layer**. There is no
stylesheet, no utility classes, and no equivalent of `tailwind.config.js`.
Anything that looks like styling belongs in the theme (`03-styling.md`).

## Banned without an approved exception

Do not add, import, or suggest any of these:

- **State / architecture:** `provider`, `bloc` / `flutter_bloc`, `get` / GetX,
  `mobx`, `redux`, `stacked`. Riverpod is the decision; it is not up for
  re-litigation per feature.
- **Routing:** `auto_route`, `beamer`, `fluro`, or hand-rolled
  `Navigator.push` route tables for anything a `go_router` route covers.
- **UI kits:** `getwidget`, `flutter_neumorphic`, `velocity_x`, `styled_widget`,
  and any package that re-implements Material primitives.
- **Styling shortcuts:** any package that mimics Tailwind/CSS in Dart
  (`tailwind_cli`, `flutter_tailwind`, utility-class extensions).
- **Animation:** `rive`, `lottie`, `flutter_animate`, `flutter_hooks`-based
  motion helpers, and every other animation package. Flutter's own framework
  covers everything the design system asks for.
- **Networking:** `dio`, `chopper`, `retrofit` — and `http` too while the app is
  mocked, because there is nothing to call.
- **Fonts:** `google_fonts` — it fetches at runtime. Bundle the family instead.
- **Utility:** `get_it` (Riverpod does DI), `intl` for anything other than real
  i18n/number/date formatting, date packages beyond `intl`.

If a task appears to *require* a banned dependency, **stop and ask a human**.
Do not add it and explain afterwards.

## Adding any dependency

An AI may not touch `pubspec.yaml` on its own initiative. Adding a package
requires:

1. a one-line justification of why nothing already in `pubspec.yaml` — or in the
   Flutter SDK itself — can do the job, and
2. explicit human approval in the conversation.

Flutter's SDK is large. Before proposing a package, check whether
`flutter/material.dart`, `flutter/widgets.dart`, `flutter/services.dart` or
`dart:*` already covers it. Most "I need a package for this" moments are a
widget you have not found yet.

## Typeface

**Plus Jakarta Sans**, bundled from `assets/fonts/` and declared in
`pubspec.yaml`. The design system names it and specifies eight type roles
against it (`08-design.md`), so this one is decided — it does not need the
per-dependency approval above. Weights needed: **500, 600, 700, 800**.

Do not add `google_fonts`: it fetches at runtime, which a mock UI with no
networking must not do. Until the font files are in `assets/fonts/`, the app
falls back to the platform sans and the type is approximately right — that is a
known gap, not something to paper over with a different family.

## Icons

**Material Icons only** — it ships with Flutter, so there is no dependency to
approve. The design system asks for two icon styles doing two different jobs
(`08-design.md`), which map cleanly onto Material's own two:

| Design system | Flutter | Where |
| --- | --- | --- |
| Solid glyph | `Icons.x` (filled) | Module tiles, active bottom nav |
| 1.9 px stroked outline | `Icons.x_outlined` | Form fields, list rows, inactive nav |

Never mix a third set, and never substitute a filled icon where the spec asks
for an outline — the two styles are how a glyph in a tile stays distinct from a
glyph beside a label.

Province and country marks are the only full-colour imagery allowed in an icon
slot: a 40 px rounded square with a Grey 200 hairline, never recoloured, never
cropped to a circle. Those are client assets — until they arrive, use the
correctly-shaped placeholder frame.

## Platform code

Dart only. Do not write Kotlin/Swift, edit `android/` or `ios/` build files, add
a platform channel, or touch entitlements/manifests without explicit approval —
those changes break other developers' builds and are invisible in review.
