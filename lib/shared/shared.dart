/// Cross-feature components.
///
/// Everything here is used by two or more features and is built from
/// `design/worksettle-design-system.md`. **Build each of these once** — a
/// second Button, Card, Chip or Field anywhere in `lib/features/` is the
/// failure mode `.agents/rules/05-reuse-and-skills.md` exists to prevent.
library;

export 'widgets/ws_buttons.dart';
export 'widgets/ws_conversation.dart';
export 'widgets/ws_feedback.dart';
export 'widgets/ws_forms.dart';
export 'widgets/ws_hero_image.dart';
export 'widgets/ws_progress.dart';
export 'widgets/ws_score_card.dart';
export 'widgets/ws_surfaces.dart';
export 'widgets/ws_theme_toggle.dart';
export 'widgets/ws_verdict_chip.dart';
export 'widgets/ws_wordmark.dart';
