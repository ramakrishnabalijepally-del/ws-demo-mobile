import 'package:flutter/material.dart';

/// The seven modules. `design/worksettle-design-system.md` section 3.
///
/// **The seven-hue spectrum is retired.** Six arbitrary hues carry no meaning a
/// user can learn, they force every screen to host a colour that competes with
/// the red, and they age badly. **Modules are told apart by their glyph** —
/// every tile is the same ink glyph on the same Grey 100 tile.
///
/// The one exception is [jobMatching], which keeps the brand red: it is the
/// entry point to the product and the place the brand should appear.
///
/// Because the tiles no longer differ by hue, **the glyph set has to work
/// harder**: each of the seven must be distinguishable in silhouette at 20 px,
/// and no two may share a dominant shape. Test them as a row of seven at final
/// size before adding an eighth.
enum WsModule {
  jobMatching(
    label: 'Job Matching',
    blurb: 'Verified, immigrant-friendly employers',
    icon: Icons.work_rounded,
    brand: true,
  ),
  profileMatching(
    label: 'Profile Matching',
    blurb: 'AI matches your profile to career and PR paths',
    icon: Icons.hub_rounded,
  ),
  eligibility(
    label: 'Immigration Eligibility',
    blurb: 'PR, PNP and federal program assessment',
    icon: Icons.verified_user_rounded,
  ),
  crsPredictor(
    label: 'CRS Predictor',
    blurb: 'Score estimate against recent draws',
    icon: Icons.speed_rounded,
  ),
  assistant(
    label: 'AI Voice & Chat',
    blurb: 'Answers on jobs, immigration and settlement',
    icon: Icons.forum_rounded,
  ),
  checklist(
    label: 'Smart Checklist',
    blurb: 'Your personalised step-by-step plan',
    icon: Icons.checklist_rounded,
  ),
  appointments(
    label: 'Appointments',
    blurb: 'Consultations with licensed RCICs',
    icon: Icons.event_available_rounded,
  );

  const WsModule({
    required this.label,
    required this.blurb,
    required this.icon,
    this.brand = false,
  });

  final String label;
  final String blurb;

  /// Solid glyph — module tiles use the filled style, not the outline
  /// (`.agents/rules/01-stack.md`).
  final IconData icon;

  /// Job Matching alone. Never true for a second module.
  final bool brand;

  /// Which modules a free account cannot open. Basic profile and job search
  /// are always free; the AI tools are Pro.
  bool get isPremium => switch (this) {
        WsModule.jobMatching => false,
        WsModule.profileMatching => true,
        WsModule.eligibility => true,
        WsModule.crsPredictor => true,
        WsModule.assistant => true,
        WsModule.checklist => true,
        WsModule.appointments => true,
      };
}
