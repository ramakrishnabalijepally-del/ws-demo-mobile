---
trigger: always_on
---

# The five rules that matter most

1. **The stack is locked.** Flutter + Dart, Material 3 `ThemeData`, `go_router`,
   Riverpod, Flutter's own animation framework. Do not introduce an
   alternative. See `01-stack.md`.
2. **Everything is feature-based.** Code lives inside the feature that owns it,
   never in a global `lib/widgets/` dumping ground. See `02-structure.md`.
3. **Search before you create.** A widget that already exists must be reused,
   not rebuilt. See `05-reuse-and-skills.md`.
4. **The theme owns colour, type and spacing.** No `Color(0xFF…)` literals, no
   hand-rolled `TextStyle`, outside `lib/app/theme/`. See `03-styling.md`.
5. **Use the skills.** If a relevant skill exists in `.claude/skills/`, invoking
   it is mandatory, not optional. See `05-reuse-and-skills.md`.

**This repo is the WorkSettle mobile app** — a native Flutter application for
iOS and Android. It is a sibling of `ws-frontend` (the React web app) and
`ws-marketing` (the marketing site). They share a brand system and a
philosophy, **not** a stack: never copy React, Tailwind, shadcn or GSAP
patterns across. Where you need the shared brand contract, it is `08-design.md`
in each repo.

**Current phase: mock UI.** Screens are being built against static fixture data
ahead of the backend. See the mock-UI protocol in `02-structure.md`.

**Audience:** every AI coding assistant used on this repository — Claude Code,
Antigravity, Cursor, Copilot, Windsurf, or anything else — and every human
reviewing what they produce.

**Status:** binding. These rules override the assistant's own defaults,
training priors, and "best practice" instincts. Where these rules and a
general design skill disagree, **these rules win**.
