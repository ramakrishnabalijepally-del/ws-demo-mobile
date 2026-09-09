# CLAUDE.md

## Read this first

This is the **WorkSettle mobile app** — Flutter + Dart, iOS and Android. It is
*not* the web app. `ws-frontend` is React/Vite/Tailwind; nothing from its stack
transfers here, only the brand contract.

This project's rules live as small topic files in `.agents/rules/`, imported
below so they load as part of this file. They are the single source of truth for
the stack, the folder structure, and the rules every AI must follow — they
override your own defaults and any general design guidance.

The same files are read natively by Antigravity, and by any other assistant
whose tool cannot import files as a plain document. Do not duplicate their rules
here — update the file under `.agents/rules/` instead.

@.agents/rules/00-core.md
@.agents/rules/01-stack.md
@.agents/rules/02-structure.md
@.agents/rules/03-styling.md
@.agents/rules/04-animation.md
@.agents/rules/05-reuse-and-skills.md
@.agents/rules/06-quality-and-verification.md
@.agents/rules/07-collaboration.md
@.agents/rules/08-design.md

## Current phase: mock UI, candidate role only

Screens are built against static fixtures ahead of the backend. No networking,
auth or storage. No employer, consultant or admin flows. See the mock-UI
protocol in `.agents/rules/02-structure.md`.

**Work from the plan:** `docs/PLAN.md` (scope, IA, the 84-screen inventory,
assumptions) and `docs/IMPLEMENTATION.md` (the ordered build sequence).

## Commands

```bash
flutter pub get                            # install packages
flutter run                                # run on a simulator/emulator/device
flutter analyze                            # must pass clean before you claim done
dart format --set-exit-if-changed lib test # must pass before you claim done
flutter test                               # widget/unit tests
flutter build apk --debug                  # Android build check
flutter build ios --debug --no-codesign    # iOS build check (macOS only)
```

`flutter pub add <package>` requires **explicit human approval** first —
see `.agents/rules/01-stack.md`.

## Design source material

**`design/worksettle-design-system-minimal-v1.md` is the primary lookup.** Read it before
building any screen — every hex, type step, radius, component spec and copy
rule is in it, and it **overrides any rule file it disagrees with**. The binding
condensation is `.agents/rules/08-design.md`.

`Screenshots/` (61 images) is a **feature inventory only** — it says which
screens exist, never what they look like. Its blue-template and old-red palettes
are not used.

## Before you finish

Run `dart format`, `flutter analyze` and `flutter test`, then work through the
verification gate in `.agents/rules/06-quality-and-verification.md` and report
the real result — including failures. If you could not run the app on a device,
say so rather than implying you saw the screen.
