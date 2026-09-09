---
trigger: model_decision
description: Apply before declaring a task done, and whenever writing or reviewing Dart for code-quality conventions — run format/analyze/test and the verification checklist.
---

# Dart quality and the verification gate

## Dart and code quality

- **No `dynamic`.** Type everything. If a type is genuinely unknown, use
  `Object?` and narrow it. `dynamic` disables the analyzer, which is the point
  of using Dart.
- **Sound null safety.** No `!` on a nullable you have not just checked, and no
  `late` used to dodge an initialisation problem. `late final x = …` for lazy
  init is fine.
- **`const` constructors everywhere possible**, on both widgets and data classes.
- **Immutable widgets.** Fields on a `StatelessWidget`/`StatefulWidget` are
  `final`. Mutable state lives in the `State` or a Riverpod notifier.
- **Every widget takes `super.key`.**
- **No dead code.** No commented-out blocks, no unused imports or fields — the
  analyzer flags them and the gate fails.
- **Prefer composition over deep inheritance.** Do not subclass a shared widget
  to change its look; add a parameter.
- **Comment the why, not the what.** Match the density of surrounding code.
- **Dispose everything you create** — controllers, focus nodes, listeners,
  subscriptions, tickers.

## Verification gate — before you say "done"

Run these and report the real output. Do not claim success without running them.

```bash
dart format --set-exit-if-changed lib test   # formatting is not optional
flutter analyze                              # must pass clean — zero issues
flutter test                                 # must pass, if tests exist
```

And, for anything visual, actually run it:

```bash
flutter run            # on a simulator/emulator or device
```

A screen you have not seen rendered is not done. If you cannot run a device in
this environment, **say so explicitly** rather than implying you verified it.

Then confirm, honestly:

- [ ] All new code is inside `lib/features/<name>/`, `lib/shared/` or `lib/app/`
- [ ] The feature has a barrel and nothing imports past it
- [ ] I searched for existing widgets — and Material's own — and stated what I reused
- [ ] No colour literals and no hand-rolled `TextStyle` outside `lib/app/theme/`
- [ ] Spacing and radii come from the scale; no magic numbers
- [ ] Light-only — no `darkTheme`, no invented dark palette (`03-styling.md` rule 5)
- [ ] `SafeArea` respected; no overflow on a 360 dp phone; scrollable where it can overflow
- [ ] Readable at 200% text scale
- [ ] Touch targets ≥ 48×48 dp
- [ ] Animations dispose their controllers and honour reduced motion
- [ ] No `pubspec.yaml` dependency was added without approval
- [ ] No `android/` or `ios/` native files were touched
- [ ] Mock/non-functional parts are marked `// TODO(backend):` and listed in my summary
- [ ] I named the skill(s) I invoked

**If something is broken or incomplete, say so plainly.** A truthful "analyze
reports two warnings in `crs_predictor`" is far more useful than an unverified
"done".

## Tests

`test/` mirrors `lib/`. For mock-UI work, a widget test that the screen builds
and does not overflow at 360 dp is worth more than a coverage number. Do not
write tests that assert on exact pixel values or colour literals — they codify
what `03-styling.md` forbids.
