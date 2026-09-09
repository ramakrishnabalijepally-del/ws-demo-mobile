---
trigger: always_on
---

# Where things live and the feature-based architecture

Package name: **`worksettle_mobile`**. Imports use
`package:worksettle_mobile/…`, never a long chain of `../../`.

## The map

```
lib/
├─ features/                  ← 95% of application code lives here
│  └─ <feature_name>/
│     ├─ presentation/
│     │  ├─ screens/          ← full routed screens
│     │  └─ widgets/          ← widgets used ONLY by this feature
│     ├─ controllers/         ← Riverpod providers / notifiers
│     ├─ data/                ← repositories, API calls, mock fixtures
│     ├─ models/              ← data classes for this feature
│     ├─ utils/               ← pure helpers for this feature
│     ├─ animations/          ← reusable motion for this feature
│     └─ <feature_name>.dart  ← THE BARREL — the only importable path
│
├─ shared/                    ← used by 2+ features, nothing feature-specific
│  ├─ widgets/                ← WsButton, WsCard, WsStatusChip, WsListRow…
│  ├─ controllers/
│  ├─ models/
│  ├─ utils/
│  └─ shared.dart             ← barrel
│
├─ app/                       ← app shell
│  ├─ theme/                  ← colours, type, spacing, ThemeExtensions
│  ├─ router/                 ← go_router config + shell/bottom-nav scaffold
│  ├─ app.dart                ← root MaterialApp.router
│  └─ providers.dart          ← app-wide Riverpod providers
│
└─ main.dart

assets/                       ← images, icons, fonts (declared in pubspec.yaml)
test/                         ← mirrors lib/ one-for-one
design/                       ← client design source material (see 08-design.md)
```

## The hard rules

**Rule 1 — A feature owns its code.**
If only one feature uses a widget, model, controller or helper, it lives in that
feature's folder. Not in `lib/widgets/`. Not in `lib/utils/`. Not in a global
`constants.dart`.

**Rule 2 — Features are imported through their barrel only.**

```dart
// ✅ correct
import 'package:worksettle_mobile/features/crs_predictor/crs_predictor.dart';

// ❌ forbidden — reaching into another feature's internals
import 'package:worksettle_mobile/features/crs_predictor/presentation/widgets/score_card.dart';
```

The barrel `export`s exactly what the outside world may use. Anything not
exported there is private to the feature.

**Rule 3 — Features do not import each other's internals, and avoid importing
each other at all.**
If feature A needs something from feature B, that something probably belongs in
`shared/`. Composition happens in `lib/app/router/`, not by cross-wiring
features.

**Rule 4 — Never create `lib/widgets/`, `lib/screens/`, `lib/utils/` or
`lib/models/`.**
They are magnets for orphaned code. Cross-feature widgets go in
`lib/shared/widgets/`.

**Rule 5 — Naming.**
Dart files and folders are `snake_case.dart` (`crs_predictor`,
`score_card.dart`) — **not** kebab-case, and **not** PascalCase; this is the one
place the web repo's convention does not carry over. Classes are `PascalCase`.
Shared widgets carry the `Ws` prefix (`WsButton`, `WsScoreCard`); feature-local
widgets do not.

**Rule 6 — One screen, one file.** A `build` method that runs past roughly 60
lines wants extracting. Extract into a **new widget class**, never a
`Widget _buildSomething()` method — helper methods defeat `const`, break
rebuild isolation, and hide the structure from the widget inspector.

**Rule 7 — Routes are registered in `lib/app/router/`.** A feature exports its
screens; it does not build its own `Navigator` or define global routes.

**Rule 8 — Sub-features.** A feature that carries several distinct flows splits
into sub-features. `jobs` is the clearest case: search, details, apply,
applications, saved and chat are six flows that share job models but not
screens.

```
lib/features/jobs/
├─ search/
│  ├─ presentation/screens/ + widgets/
│  ├─ controllers/
│  └─ data/
├─ details/
├─ apply/
├─ applications/
├─ saved/
├─ chat/
├─ models/          ← shared by the whole feature
├─ data/mock/       ← fixtures shared by the whole feature
├─ widgets/         ← widgets used by 2+ sub-features (WsJobCard)
└─ jobs.dart        ← THE barrel — sub-features do not get one
```

- A sub-feature mirrors the feature layout minus the barrel.
- **Sub-features of the same feature may import each other's internals.** The
  barrel rule binds *across* features, not inside one.
- Anything used by two sub-features moves up to the feature's own `models/`,
  `data/` or `widgets/` — not into `lib/shared/`, which is for things two
  *features* need.
- Split when a feature reaches three flows or roughly ten screens. Below that,
  a flat feature is correct and a sub-feature folder is ceremony.

## Mock UI protocol — current phase

The app is being built as a mock ahead of the backend. Until told otherwise:

- Fixture data lives in `features/<name>/data/mock/` as plain Dart constants,
  named `mock*` (`mockCrsResult`, `mockJobs`). Never scatter literals through
  widget code.
- Every screen reads its data through the feature's controller/repository even
  when that repository just returns a fixture — so swapping in the real API is a
  one-file change, not a rewrite.
- **Do not add networking, auth, storage or a backend client** unless asked. No
  API keys, no endpoints, no `.env`.
- Mark anything intentionally non-functional with a `// TODO(backend):` comment
  and say so in your summary. A button that silently does nothing is a bug
  report waiting to happen.

## Creating a new feature — the ordered checklist

Follow these in order. Do not skip step 1.

1. **Search `lib/features/`** for an existing feature that already covers this
   ground. Extend it rather than creating a near-duplicate.
2. **Create the folder** `lib/features/<snake_name>/` with only the subfolders
   you actually need — do not scaffold empty directories.
3. **Inventory reusable widgets first** — list what you will reuse before you
   write a single new one. See `05-reuse-and-skills.md`.
4. **Invoke the relevant skill** before designing any UI. See
   `05-reuse-and-skills.md`.
5. **Build the screens**, taking every colour, text style and gap from the
   theme. See `03-styling.md`.
6. **Add motion** with Flutter's animation framework. See `04-animation.md`.
7. **Write the barrel** exporting only the public surface.
8. **Register the route** in `lib/app/router/`.
9. **Run the verification gate** and report the result honestly. See
   `06-quality-and-verification.md`.
