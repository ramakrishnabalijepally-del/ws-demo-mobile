# AGENTS.md

Instructions for any AI coding agent working in this repository — Antigravity,
Cursor, Copilot, Codex, Windsurf, Claude Code, or anything else.

**This is the WorkSettle mobile app: Flutter + Dart, iOS and Android.** Its
sibling `ws-frontend` is a React web app. They share a brand, not a stack —
never port React, Tailwind, shadcn or GSAP patterns into this repo.

## Mandatory first step

The full, current rules live as small topic files in
[`.agents/rules/`](./.agents/rules/). Antigravity loads these natively. If your
tool does not auto-discover that folder, **read every file in it before your
first edit** — they are short and it takes a minute.

Do not duplicate rule *content* here. This file is the always-loaded summary; if
a rule needs to change, change it in `.agents/rules/` first.

## Non-negotiables (summary — the full rules are in .agents/rules/)

1. **Locked stack.** Flutter (stable) + Dart 3, Material 3 `ThemeData`,
   `go_router`, `flutter_riverpod`, Flutter's own animation framework, Plus
   Jakarta Sans bundled, Material Icons (filled + outlined). **That is the whole
   dependency list.** Do not introduce `provider`, `bloc`, GetX, `mobx`,
   `auto_route`, `dio`/`http`, `get_it`, `google_fonts`, a third-party UI kit,
   or any animation package. If a task seems to need one, **stop and ask a
   human**. See `.agents/rules/01-stack.md`.
2. **No `pubspec.yaml` dependency without explicit human approval.** Check the
   Flutter SDK first — most "I need a package" moments are a widget you have not
   found yet.
3. **Feature-based structure.** All code lives in
   `lib/features/<snake_name>/` (`presentation/screens/`,
   `presentation/widgets/`, `controllers/`, `data/`, `models/`, `utils/`,
   `animations/`, `<feature_name>.dart` barrel). Cross-feature code goes in
   `lib/shared/`; app shell in `lib/app/`. Never create `lib/widgets/` or
   `lib/screens/`. See `.agents/rules/02-structure.md`.
4. **Import features only through their barrel.** Never reach into another
   feature's internal files. Files are `snake_case.dart`, classes `PascalCase`,
   shared widgets get a `Ws` prefix.
5. **Reuse before creating.** Check `lib/shared/widgets/` — and Flutter's own
   Material widgets — first, and state in your response what you reused, or
   exactly why nothing existing fits. See `.agents/rules/05-reuse-and-skills.md`.
6. **No hardcoded colours or hand-rolled `TextStyle`s.** Everything comes from
   `Theme.of(context)` — `colorScheme`, `textTheme`, and the `WsColors`
   `ThemeExtension`. Colour literals may appear only in `lib/app/theme/`. The
   palette is **one red (`#E4101B`) and one true-neutral grey ramp, and nothing
   else** — no second accent hue enters the system. See
   `.agents/rules/03-styling.md`.
6b. **Both themes are real.** Build light and dark; `themeMode` is driven by
   Settings → Appearance. Settle Red is unchanged where it fills a shape; red
   as text/border/icon is `#B00A13` light, `#EE6A6F` dark.
7. **Restyle Material, do not replace it.** Component looks are set once in
   `ThemeData`'s component themes. No near-identical wrapper widgets, no
   per-call-site styling.
8. **Animate with Flutter's framework** — implicit animations first, explicit
   controllers disposed, durations from `WsMotion`, and always a reduced-motion
   branch (`MediaQuery.disableAnimationsOf`). See `.agents/rules/04-animation.md`.
9. **Use the project skills.** `.claude/skills/` contains `ui-ux-pro-max` (use
   its `flutter.csv` stack data), `impeccable` (use its **native** references:
   `android.md`, `ios.md`, `adapt.native.md`, `audit.native.md`) and
   `frontend-design` (web-oriented — take the craft, drop the HTML/CSS). If your
   tool cannot execute skills, read the relevant
   `.claude/skills/<name>/SKILL.md` as a document and follow it. Name which one
   you applied.
10. **Stay in your lane.** Several developers work here in parallel. Touch only
    the feature you were asked to build; never reformat unrelated files, run
    `flutter pub upgrade`, or edit `android/`/`ios/` native files. See
    `.agents/rules/07-collaboration.md`.
11. **`design/worksettle-design-system-minimal-v1.md` is the primary lookup for all UI.**
    Read it before designing anything; it carries every colour, type step,
    radius, component spec and copy rule. If it disagrees with any rule file,
    **the design system wins and the rule file gets fixed.** The binding
    condensation is `.agents/rules/08-design.md`. In short: one red
    (`#E4101B`) plus a true-neutral grey and **no other hue anywhere**; module
    identity comes from the glyph, not colour; **every button is a full pill**;
    state is a filled → outlined → tinted ladder where **every chip must carry
    its glyph**; red is brand and action only and is **never a state colour**;
    the hairline is the boundary and the shadow only says how high.
11b. **`Screenshots/` is a feature inventory, not a design.** Those 61 images
    come from a blue job-portal template and an older red deck. They say which
    screens exist. **Neither palette is used** — every value comes from the
    design system.
12. **Five fixed destinations** — Home · Jobs · Immigration · Settlement ·
    Profile — as a `StatefulShellRoute` with a persistent `NavigationBar`, each
    tab keeping its own stack.
13. **Mock-UI phase, candidate role only.** Build screens against fixtures in
    `<feature>/data/mock/`, read through the feature's controller. No backend,
    auth, storage or networking. No employer, consultant or admin flows. Mark
    non-functional parts `// TODO(backend):` and list them in your summary.
14. **The plan is written.** `docs/PLAN.md` (scope, IA, 84-screen inventory,
    assumptions) and `docs/IMPLEMENTATION.md` (the ordered build). Work from
    them; update them when reality diverges.

## Commands

```bash
flutter pub get
flutter run                                # see it on a device before claiming done
flutter analyze                            # must pass clean
dart format --set-exit-if-changed lib test # must pass
flutter test
```

`flutter pub add <package>` needs approval first.

## Definition of done

Run `dart format`, `flutter analyze` and `flutter test`, complete the
verification checklist in `.agents/rules/06-quality-and-verification.md`, and
report the real result — including any failures. A screen you have not seen
rendered is not done; if you could not run a device, say so. Never claim success
you have not verified.
