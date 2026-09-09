---
trigger: always_on
---

# Working alongside other developers

Several people run AI assistants against this repo at the same time.

- **Stay in your lane.** Touch only the feature you were asked to build. Do not
  opportunistically refactor another feature, reformat unrelated files, or
  "tidy up" code outside your task.
- **Shared files are high-traffic.** `lib/app/theme/**`, `lib/app/router/**`,
  `lib/shared/**` and `pubspec.yaml` are edited by everyone. Change them only
  when the task genuinely requires it, keep the change additive, and call it out
  explicitly in your summary.
- **Never run `dart format` across the whole repo** to fix your own file. Format
  what you touched.
- **Never bump, remove or re-pin someone else's dependency** as a side effect —
  and never run `flutter pub upgrade`. `pubspec.lock` churn is a merge conflict
  for everyone.
- **Never touch `android/`, `ios/`, or generated files** (`*.g.dart`,
  `*.freezed.dart` — regenerate them, do not hand-edit) without saying so.
- **Report what you touched** — end every task with the list of files changed.

## The three WorkSettle repos

`ws-moblie-frontend` (this repo, Flutter — the folder name's typo is intentional
to leave alone) · `ws-frontend` (React web app) · `ws-marketing` (marketing
site).

They share the brand contract in `08-design.md` and nothing else. Do not port
code between them — only decisions. If you change a brand token here, say so in
your summary so a human can mirror it; do not edit another repo yourself unless
asked.
