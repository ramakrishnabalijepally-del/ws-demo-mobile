---
trigger: model_decision
description: Apply when writing or editing any widget's visual appearance — colours, text styles, spacing, padding, radii, shadows, ThemeData, or Material component usage.
---

# Styling rules

Flutter has no stylesheet. **The theme is the stylesheet**, and it lives in
`lib/app/theme/`. Every visual decision resolves through it.

**Rule 1 — Never hardcode a colour.** Not `Colors.red`, not `Color(0xFFE11B22)`,
not `Colors.white`. The only files where a colour literal may appear are inside
`lib/app/theme/`.

```dart
// ✅ correct
Container(
  color: Theme.of(context).colorScheme.surface,
  child: Text('Hello', style: Theme.of(context).textTheme.titleMedium),
)

// ❌ forbidden
Container(
  color: const Color(0xFFFFFFFF),
  child: const Text('Hello', style: TextStyle(fontSize: 16, color: Colors.black)),
)
```

`ColorScheme` covers the neutrals and the brand red. The **seven feature
accents** and any other WorkSettle-specific colour live on a `ThemeExtension`
(`WsColors`) so they are still theme lookups, not literals:

```dart
final accents = Theme.of(context).extension<WsColors>()!;
Icon(icon, color: accents.crs); // purple — the CRS feature accent
```

If you need a colour that has no token, **add the token** in
`lib/app/theme/colors.dart` — then use it, and flag it in your summary so the
same token can be mirrored into `ws-frontend/src/index.css` and
`ws-marketing/src/styles/global.css`. The three WorkSettle apps must not drift.

**Rule 2 — Never hand-roll a `TextStyle`.** Take it from `textTheme` and adjust
with `copyWith` only for weight or colour, never for a new font size:

```dart
Text(
  '468',
  style: Theme.of(context).textTheme.displaySmall
      ?.copyWith(color: Theme.of(context).colorScheme.primary),
)
```

Numbers that stack in a column — score breakdowns, price tables — are set in
**tabular figures** (`FontFeature.tabularFigures()`), already applied to the
`metric` role, so digits share one width and the column aligns.

**Rule 3 — Spacing and radii come from the scale.** `lib/app/theme/spacing.dart`
defines the spacing scale (`WsSpacing.sm/md/lg…`) and the corner radii
(`WsRadii`). No magic numbers in `EdgeInsets` or `BorderRadius`.

**Rule 4 — Restyle Material, do not replace it.** Component appearance is set
once via `ThemeData`'s component themes (`filledButtonTheme`, `cardTheme`,
`inputDecorationTheme`, `navigationBarTheme`…). Do not wrap `FilledButton` in a
near-identical custom widget, and do not style the same button twice at two call
sites. If a component needs a WorkSettle-specific shape that theming cannot
express, it becomes a shared `Ws*` widget — once — in `lib/shared/widgets/`.

**Rule 5 — Both themes are real.** Dark is a full second theme, not a filter
over the light one, and it is specified end to end in
`design/worksettle-design-system-minimal-v1.md` §2. Build `WorkSettleTheme.light` **and**
`.dark`; `themeMode` is app state driven by Settings → Appearance → Dark Mode.

Three things shape it:

- **The ramp inverts, the brand red does not.** A filled action is `#E4101B`
  with a white label in both themes — the product's one loud object looks the
  same to everyone.
- **Red as text, border or icon does change**: `#B00A13` at body size on light,
  `#EE6A6F` on dark. Never set paragraph text in the base red.
- **Voice mode is `#000000` in both themes.** It is the one place the two
  themes converge rather than invert.

No screen may be defined in one brightness only, and nothing may branch on
`Theme.of(context).brightness` to pick a colour — that is what the token layer
is for. Brightness may only be read for things a token cannot express (an
asset variant, a `SystemUiOverlayStyle`).

**Rule 5b — The radius encodes the shape of the thing.** Anything you press is
a full pill (999); anything that holds content is 16; a list row is 14;
anything you type into is 12; a compact tile is 10; a checkbox is 6. That
difference is how a button and an input stay distinguishable at a glance in a
form — never round them the same.

**Rule 6 — `const` everywhere it compiles.** `const` widgets are skipped on
rebuild. `prefer_const_constructors` is on and the analyzer will tell you.

**Rule 7 — Respect the device, not a breakpoint.**

- Wrap screen content in `SafeArea`; never assume a notch-free rectangle.
- Layouts must survive **text scaling** — the OS setting can reach 200%. Do not
  trap text in a fixed-height box. Prefer intrinsic sizing and
  `Flexible`/`Expanded` over hardcoded heights.
- Design for the small phone first (≈360 dp wide) and let it breathe on large
  phones (≈430 dp). Tablet and landscape layouts are **out of scope** until a
  human asks — do not speculatively add `LayoutBuilder` branches.
- Anything that can exceed the viewport gets a real scroll view. A `Column` that
  overflows on a small phone is a failed screen, not a warning.

**Rule 8 — Touch targets are at least 48×48 dp**, with real spacing between
them. A hard accessibility floor, not a suggestion.

## Assets

Images, fonts and icon assets live in `assets/` and are declared in
`pubspec.yaml` (an asset declaration is not a dependency change, but still call
it out). Use `flutter_svg` only if it is already in `pubspec.yaml`. Never inline
a base64 blob into Dart source.
