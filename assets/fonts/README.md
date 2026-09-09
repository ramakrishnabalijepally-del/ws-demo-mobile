# assets/fonts/

The design system (`design/worksettle-design-system.md` section 4) specifies
**Plus Jakarta Sans** as the one family across the whole product.

Four weights are used:

| Weight | File | Used by |
| --- | --- | --- |
| 500 | `PlusJakartaSans-Medium.ttf` | body, caption |
| 600 | `PlusJakartaSans-SemiBold.ttf` | metric denominator, presence |
| 700 | `PlusJakartaSans-Bold.ttf` | title, label, overline, buttons |
| 800 | `PlusJakartaSans-ExtraBold.ttf` | display, title-lg, metric |

Drop the four files here, then uncomment the `fonts:` block in `pubspec.yaml`.

Until they are present the app falls back to the platform sans: sizes, weights
and tracking are correct, the letterforms are not. Do **not** substitute a
different family, and do **not** add `google_fonts` — it fetches at runtime
(`.agents/rules/01-stack.md`).
