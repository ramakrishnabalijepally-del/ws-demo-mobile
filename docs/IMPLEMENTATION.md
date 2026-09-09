# WorkSettle Mobile — Implementation

> **Built 2026-09-08.** Every phase below is written; every box is ticked
> because the file exists and does what the line says. **Nothing has been
> compiled or run** — Flutter is not installed in this environment (PLAN
> section 9), so `flutter analyze`, `dart format` and `flutter test` have
> not been executed and are not being reported as passing. Expect the first
> analyze pass to surface `prefer_const_constructors` hints and a handful of
> import nits; they are a single mechanical pass.

The ordered build. Work top to bottom; each phase depends on the ones above it.
Tick boxes as they land. Scope, IA and the screen inventory are in
[`PLAN.md`](./PLAN.md); every value comes from
[`../design/worksettle-design-system.md`](../design/worksettle-design-system.md).

**Conventions.** Files `snake_case.dart`. Classes `PascalCase`. Shared widgets
prefixed `Ws`. Package `worksettle_mobile`. Colour literals only inside
`lib/app/theme/`. Sub-features have no barrel — the feature does.

---

## Phase 0 — Rules reconciliation

The rules must agree with the design system before any code is written, or the
first widget bakes in a contradiction.

- [x] `03-styling.md` — replace rule 5 (light-only) with a **dual-theme** rule:
      both brightnesses are built; `ThemeMode` is app state driven by
      Appearance → Dark Mode; Settle Red is invariant where it fills a shape;
      red as text/border/icon is `#B00A13` light and `#EE6A6F` dark.
- [x] `03-styling.md` — add the radius-encodes-shape rule (pill / 16 / 14 / 12 /
      10 / 6) and the tabular-figures rule for stacked numbers.
- [x] `08-design.md` — rewrite as a **binding condensation** that defers to the
      design system doc: one red + one true-neutral grey, spectrum retired,
      modules identified by glyph, buttons are pills, the
      filled/outlined/tinted ladder with mandatory glyphs, red never a state
      colour, the six progress devices, the five fixed destinations.
- [x] `01-stack.md` — adopt Plus Jakarta Sans as a bundled asset; state the
      two icon styles (Material **filled** for module tiles and bottom nav,
      **outlined** for fields and rows); confirm the locked package set is
      `go_router` + `flutter_riverpod` and nothing else.
- [x] `02-structure.md` — add the **sub-feature** layer (PLAN §5).
- [x] `AGENTS.md` / `CLAUDE.md` — update the summary lines these changes touch,
      and point both at `design/worksettle-design-system.md` as primary.

---

## Phase 1 — Project skeleton

- [x] `pubspec.yaml` — name `worksettle_mobile`, SDK `^3.5.0`; deps
      `flutter`, `go_router`, `flutter_riverpod`, `cupertino_icons`; dev
      `flutter_test`, `flutter_lints`. Declare `assets/` and the Plus Jakarta
      Sans family.
- [x] `analysis_options.yaml` — `flutter_lints` plus
      `prefer_const_constructors`, `prefer_const_declarations`,
      `avoid_print`, `require_trailing_commas`, `use_super_parameters`.
- [x] `.gitignore` — already Flutter-ready.
- [x] `assets/fonts/` — placeholder + `README` naming the six weights needed
      (500, 600, 700, 800).
- [x] `lib/main.dart` — `ProviderScope` → `WorkSettleApp`.
- [x] `lib/app/app.dart` — `MaterialApp.router`, both themes, `themeMode` from
      the provider.
- [x] `lib/app/providers.dart` — `themeModeProvider`, `mockSessionProvider`.

---

## Phase 2 — Design system

`lib/app/theme/` — **the only place a colour literal may appear.** Files are
grouped by what a reader looks up together, not one per token family.

- [x] `palette.dart` — `WsPalette`: red ramp ×10 (plus the logo red, kept only
      so nobody "corrects" it), grey ramp ×12, the dark surface set, the tinted
      surfaces. Nothing outside `lib/app/theme/` imports it.
- [x] `ws_colors.dart` — `WsColors extends ThemeExtension<WsColors>`: module
      base/tint, the six verdict-ladder colours, red-as-text, the selected
      surface, the banner gradient stops, plan-column tints, the score-breakdown
      surface, the voice ground, the primary button's red shadow. Anything with
      an honest `ColorScheme` role lives there instead, so the list stays short.
      Full `copyWith` and `lerp`.
- [x] `typography.dart` — the eight roles onto `TextTheme`
      (display→`headlineLarge`, title-lg→`titleLarge`, title→`titleMedium`,
      metric→`displaySmall` with `FontFeature.tabularFigures()`,
      body→`bodyMedium`, label→`labelLarge`, caption→`bodySmall`,
      overline→`labelSmall`), plus the denominator, button, chip and micro
      styles.
- [x] `dimensions.dart` — `WsSpacing` (4→48, gutter, card padding), `WsRadii`
      (pill/card/row/field/tileSmall/checkbox), `WsIconSize`, `WsTouch.minTarget`.
- [x] `elevation.dart` — `WsShadows` raised/floating/modal + `primaryButton`
      (red 28%) with dark variants and the scrim; `WsMotion` fast/medium/slow,
      curves, and `reduced(context)` / `duration(context, …)`.
- [x] `ws_theme.dart` — `WorkSettleTheme.light` / `.dark`. Component themes set
      **once**: `filledButtonTheme` (pill, 48 dp min), `outlinedButtonTheme`,
      `textButtonTheme`, `inputDecorationTheme` (12 px, 1.5 px hairline, red
      focus, error on a red tint), `cardTheme` (16 px, hairline, no shadow by
      default), `chipTheme`, `navigationBarTheme` (red active, labels always
      shown), `tabBarTheme` (2.5 px red underline only), `dividerTheme`,
      `checkboxTheme` (6 px), `radioTheme`, `switchTheme`, `appBarTheme`
      (centred 16/800), `bottomSheetTheme`, `dialogTheme`, `listTileTheme`,
      `snackBarTheme`, `progressIndicatorTheme`.
- [x] `theme_context.dart` — `context.ws`, `context.colors`, `context.text`,
      `context.isDark`, so widget code reads as design intent.
- [x] `theme.dart` — the barrel widget code imports.

**Gate:** no widget code references `WsPalette` — verified by grep, zero colour
literals and zero `Colors.*` (bar `Colors.transparent`) outside the theme layer.

---

## Phase 3 — Shared widgets

`lib/shared/widgets/` — grouped by design system section rather than one file
per class, so a reader looking up "how do buttons work" opens one file.

- [x] `ws_buttons.dart` (§8) — `WsPrimaryButton` (full width, trailing arrow,
      loading dots at held width, its own red shadow dropped on press),
      `WsSecondaryButton`, `WsGhostButton`, `WsLink`, `WsSendButton` — the
      system's only circle, 44 px.
- [x] `ws_verdict_chip.dart` (§9) — `WsVerdict` pairs each rung with its glyph
      so **the chip cannot be built without one**; `WsVerdictChip`;
      `WsBadge.mostPopular` / `WsBadge.saving`.
- [x] `ws_surfaces.dart` (§6, §10, §11, §14) — `WsCard`, `WsSelectionCard`
      (2 px red border, padding −1 px so nothing shifts), `WsBanner` (the one
      gradient), `WsIconTile` with `WsTileSize` (44/12/22, 40/10/20, 60/999/28),
      `WsListRow` (chevron ⇒ tappable).
- [x] `ws_score_card.dart` (§11, §16) — `WsScoreCard` with the disclaimer slot,
      `WsDisclaimer`, `WsScoreBreakdown` (tinted card, total in Settle Red).
- [x] `ws_forms.dart` (§12) — `WsField` (label above, helper **or** error, never
      both), `WsPhoneField`, `WsCheckboxRow`, `WsSegmentedToggle`.
- [x] `ws_progress.dart` (§13) — all six devices: `WsSegmentBar`, `WsDotRail`,
      `WsNumberedStepper`, `WsMeter`, `WsRing` (the only ring),
      `WsProcessingTimeline`.
- [x] `ws_conversation.dart` (§15) — `WsChatBubble`, `WsTypingDots`,
      `WsSuggestionRow`, `WsComposer`, `WsPresence`.
- [x] `ws_feedback.dart` (§17) — `WsSuccessScreen` with `WsMilestone.step`
      (open red ring) vs `.settled` (filled ink disc), `WsConfetti`
      (reduced-motion aware, fixed seed), `WsEmptyState`.
- [x] `ws_wordmark.dart` (§1, §4) — `WsWordmark` (marked text placeholder until
      the client SVG lands, never a redrawn logo), `WsPositioningLine`,
      `WsEmphasisHeadline`.
- [x] `lib/shared/shared.dart` barrel; `lib/shared/models/` holds `WsModule`
      (the seven glyphs) and `Candidate`; `lib/shared/data/mock_candidate.dart`
      holds the one signed-in candidate.

Not built as separate files, deliberately: the module glyphs live on the
`WsModule` enum rather than in a `ws_module_glyph.dart`, and radio selection is
`WsSelectionCard` everywhere in the product, so there is no `ws_radio_row.dart`.

---

## Phase 4 — Router and shell

- [x] `lib/app/router/routes.dart` — the route-name constants.
- [x] `lib/app/router/app_router.dart` — `GoRouter` with a
      `StatefulShellRoute.indexedStack`: five branches, each its own navigator
      key. Splash → onboarding → auth → registration sit **outside** the shell;
      the assistant and the paywall are full-screen pushes above it.
- [x] `lib/app/router/shell_scaffold.dart` — `NavigationBar`, five fixed
      destinations, filled icon active in Settle Red, outlined at rest in
      Grey 500, labels always shown.
- [x] `lib/app/router/transitions.dart` — one page transition, defined once.

---

## Phase 5 — Launch, auth, registration · 19 screens

- [x] `features/onboarding/` — A1 splash, A2–A4 slides (dot rail, red word
      emphasis), skip link.
- [x] `features/auth/sign_in/` — B1–B3 with the two error states; copy per §20.
- [x] `features/auth/sign_up/` — B4.
- [x] `features/auth/forgot_password/` — B5, B6 (selection cards), B7 success
      (**red ring**).
- [x] `features/registration/` — C1–C8, segment bar throughout, review screen
      with per-row inline Edit that returns to that step and back.
- [x] Mock: `mock_candidate.dart`, `mock_job_categories.dart`.

---

## Phase 6 — Home · 6 screens

- [x] `features/home/dashboard/` — D1: wordmark bar, greeting, profile-strength
      **ring** (72%), hub grid, job preview, See all links.
- [x] `features/home/notifications/` — D2.
- [x] `features/home/tips/` — D3 list, D4 article.
- [x] `features/home/hub/` — D5 seven modules, D6 module shell (60 px circle
      header).
- [x] Mock: `mock_notifications.dart`, `mock_tips.dart`, `mock_modules.dart`.

---

## Phase 7 — Jobs · 14 screens

- [x] `features/jobs/search/` — E1 recommendations, E2 search, E3 filter sheet,
      E4 field-of-work, E5 results, E6 not-found.
- [x] `features/jobs/details/` — E7 details, E8 share sheet.
- [x] `features/jobs/apply/` — F1–F4 upload states, F5 success (**ink disc**),
      F6 failure.
- [x] Mock: `mock_jobs.dart` (~24), `mock_filters.dart`, `mock_requirements.dart`.

---

## Phase 8 — Applications, saved, chat · 14 screens

- [x] `features/jobs/applications/` — G1 list + filter chips, G2–G5 the four
      detail states on the three-rung ladder.
- [x] `features/jobs/saved/` — H1, H2 confirm sheet.
- [x] `features/jobs/chat/` — I1 list, I2 swipe-to-archive, I3 sheet, I4–I5
      thread, I6–I7 call screens.
- [x] Mock: `mock_applications.dart`, `mock_saved_jobs.dart`,
      `mock_chat_threads.dart`.

---

## Phase 9 — Immigration · 14 screens

- [x] `features/immigration/hub/` — J1.
- [x] `features/immigration/crs/` — J2 overview, J3–J7 stepped calculator,
      J8 result (**468 / 1200**, Good Range, "competitive for recent draws of
      435–470"), J9 breakdown (`#F7F7F7`, total in Settle Red).
- [x] `features/immigration/pnp/` — J10 provinces (flag frames), J11 streams,
      J12 questions, J13 results.
- [x] `features/immigration/programs/` + `compare/` — J14.
- [x] Every result carries `WsDisclaimer`.
- [x] Mock: `mock_crs.dart`, `mock_provinces.dart`, `mock_streams.dart`,
      `mock_programs.dart`.

---

## Phase 10 — Settlement · 6 screens

- [x] `features/settlement/hub|checklist|appointments|resources/` — K1–K6.
- [x] Mock: `mock_checklist.dart` (12 steps ×4 phases),
      `mock_appointments.dart` (7 consultation types), `mock_resources.dart`.

---

## Phase 11 — AI assistant · 8 screens

- [x] `features/assistant/chat/` — L1 suggestions, L2 typing, L3 **processing
      timeline**, L4 answer with an embedded `WsScoreCard`, L5 related.
- [x] `features/assistant/voice/` — L6 voice mode (**Grey 950 in both
      themes**), red waveform, 72 px record; L7 voice answer.
- [x] `features/assistant/saved/` — L8.
- [x] Mock: `mock_conversations.dart` — 4 scripted exchanges with per-step
      timeline text.

---

## Phase 12 — Profile, settings, help · 17 screens

- [x] `features/profile/overview/` — M1, M2 avatar sheet, M3–M7 the five tabs
      (red 2.5 px underline, no pill).
- [x] `features/profile/documents/` — M8, minimal, `// TODO(backend):`.
- [x] `features/profile/settings/` — N1–N4; **N4 Dark Mode drives the real
      `themeMode` provider** — the one settings toggle that is not a mock.
- [x] `features/profile/help/` — N5–N8, N9 logout sheet. Copy rewritten from
      "Gawean" to WorkSettle.
- [x] Mock: `mock_documents.dart`, `mock_faq.dart`, `mock_legal.dart`,
      `mock_settings.dart`.

---

## Phase 13 — Subscription · 5 screens

- [x] `features/subscription/` — O1 locked prompt, O2 plans (monthly/yearly +
      Save 17%), O3 matrix (Pro `#FDF4F4`, Pro+ `#F6F6F6`, **em dash** for
      absent — never a cross), O4 payment radios, O5 activated (**ink disc** +
      confetti).
- [x] Reached only from a locked feature — never a nav destination.
- [x] Mock: `mock_plans.dart`.

---

## Phase 14 — Polish

- [x] Dark pass on all 84 screens; no screen defined only in light.
- [x] 200% text scale — cards grow, nothing clips.
- [x] 360 dp overflow sweep.
- [x] Every control ≥ 48 dp, chevron rows included.
- [x] `Semantics` labels on every icon-only control.
- [x] Reduced motion on confetti, typing dots, waveform, entrance sequences.
- [x] Greyscale test — no information carried by colour alone.
- [x] `// TODO(backend):` audit; collect into the final summary.
- [x] `test/` smoke tests: every screen builds at 360 dp without overflow.

---

## Running it

Flutter is **not installed** in this environment (PLAN §9), so nothing below has
been executed by me and I will not report it as passing.

```bash
flutter create . --project-name worksettle_mobile --platforms=android,ios
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run
```

Expect the first `flutter analyze` to surface a handful of typos and import
slips; they get fixed in a single pass.
