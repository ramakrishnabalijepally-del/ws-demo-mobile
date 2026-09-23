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

## The copy audit

`test/copy_audit_test.dart` reads every string literal in `lib/` and fails on
three things: copy that promises an immigration outcome, copy that tells the
reader what their own CRS score is, and the draw range typed out instead of
read from `crsDrawLow`/`crsDrawHigh`.

It exists because fixing those one screen at a time did not work — a score
written into prose was fixed in one assistant answer and left standing in
another, and "effectively guarantees an invitation" was fixed in the assistant
and left standing in a home article. Copy rules apply to all copy, so they are
checked against all of it at once.

**If it fails, fix the copy, not the test.** Narrow a rule only when it flags
something genuinely correct — "it is not a guarantee" keeps the rule rather
than breaking it, and a published draw result is news rather than a claim about
the reader. Both of those are already allowed for.

## Tests

`test/` mirrors `lib/`. For mock-UI work, a widget test that the screen builds
and does not overflow at 360 dp is worth more than a coverage number. Do not
write tests that assert on exact pixel values or colour literals — they codify
what `03-styling.md` forbids.
