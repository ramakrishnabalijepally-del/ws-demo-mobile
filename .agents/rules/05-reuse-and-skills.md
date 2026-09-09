---
trigger: model_decision
description: Apply before creating any new widget or starting any UI/design work — check for existing shared/Material widgets first, and invoke the required design skill.
---

# Reuse before you create, and use the required skills

## Reuse protocol — mandatory

This is the rule AI assistants break most often. Before creating **any** widget,
do this and show your work:

```bash
# 1. Do we already have a shared widget for it?
ls lib/shared/widgets/

# 2. Does another feature already have something similar?
grep -ril "card" lib/features --include=*.dart

# 3. Is it just a themed Material widget?
#    Card, Chip, FilledButton, OutlinedButton, ListTile, TextField,
#    NavigationBar, LinearProgressIndicator, Stepper, ExpansionTile…
```

Then state, in your response, one of:

- **"Reusing `WsScoreCard` from `lib/shared/widgets/`"** — the default outcome, or
- **"Creating `X` because no existing widget does Y"** — with the specific reason
  nothing existing fits.

**Check Flutter's SDK before you check anything else.** A large share of
"new components" are a `Card`, `Chip`, `ListTile` or `NavigationBar` that only
needed theming (`03-styling.md` rule 4). Never build a second Button, Card,
Chip, Dialog, TextField, Spinner, EmptyState or SnackBar.

### The promotion rule

The moment a widget is needed by a **second** feature:

1. move it to `lib/shared/widgets/`,
2. give it the `Ws` prefix and strip out anything feature-specific (make it
   configurable via constructor parameters),
3. update both call sites, and export it from `lib/shared/shared.dart`.

Do not copy-paste it into the second feature. Copy-paste is the failure mode
this whole document exists to prevent.

## Skills and agents — mandatory, not optional

This repository ships its own skills in `.claude/skills/` and agents in
`.claude/agents/`. **They are committed so every developer and every AI has
them.** Using them is required, not a suggestion.

| Skill | Invoke it when |
| --- | --- |
| `ui-ux-pro-max` | building or reviewing any screen, component, layout or colour system — it carries a **`flutter.csv`** stack dataset; use that one |
| `impeccable` | polishing, auditing, animating or critiquing existing UI — it has **native** references (`android.md`, `ios.md`, `adapt.native.md`, `audit.native.md`); use those, not the web path |
| `frontend-design` | aesthetic direction, palette and typography for a *new* surface — **web-oriented; take the craft, discard the HTML/CSS specifics** |

**Rule 1 — Before designing any new screen or significant widget, invoke the
relevant skill first.** Do not design from your own taste when a skill covers
the task.

**Rule 2 — Read the native path, not the web path.** These skills were brought
over from `ws-frontend`. Wherever one talks about HTML, CSS, Tailwind, the DOM,
a browser viewport, or a React component, translate it to the Flutter
equivalent — or drop it. Their *craft* transfers; their *implementation
guidance* frequently does not.

**Rule 3 — Say which skill you used.** Your response must name the skill(s)
invoked, so the reviewer can tell the guidance was actually applied.

**Rule 4 — Project rules beat skill advice.** If a skill suggests a different
folder layout, a web animation library, or a styling approach that is not the
theme, **the rules in this `.agents/rules/` folder win**. Skills supply craft;
these rules supply the constraints. `08-design.md` beats any skill on brand.

**Rule 5 — For non-Claude tools.** If your tool cannot execute skills, read the
relevant `.claude/skills/<name>/SKILL.md` as a plain document and follow it.
