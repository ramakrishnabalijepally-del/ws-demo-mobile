import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// App-wide state.
///
/// Everything here is in-memory only: the app is a mock UI with no storage
/// (`.agents/rules/02-structure.md`). A restart returns to defaults, which is
/// the intended behaviour for now.

/// Drives the real `MaterialApp.themeMode`.
///
/// Settings > Appearance > Dark Mode writes to this. It is the one settings
/// toggle in the app that is not a mock.
final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  /// Light, not `system`.
  ///
  /// The design system is a light-first product — white cards on a faint grey
  /// canvas is the look it describes, and dark is the second theme. Defaulting
  /// to `system` would hand that decision to whichever machine happens to open
  /// the app, so a reviewer on a dark-mode laptop would see the wrong thing
  /// first. Settings > Appearance still offers dark and "follow my device".
  @override
  ThemeMode build() => ThemeMode.light;

  void setDark(bool value) => state = value ? ThemeMode.dark : ThemeMode.light;

  /// Hand the decision back to the platform.
  void followSystem() => state = ThemeMode.system;

  /// True when the app is currently rendering dark, resolving `system` against
  /// the platform.
  bool isDark(BuildContext context) => switch (state) {
        ThemeMode.dark => true,
        ThemeMode.light => false,
        ThemeMode.system =>
          MediaQuery.platformBrightnessOf(context) == Brightness.dark,
      };
}

/// Whether the mock candidate has completed onboarding and signed in.
///
/// Gates the router: false sends you to the splash and onboarding flow.
final signedInProvider =
    NotifierProvider<SignedInNotifier, bool>(SignedInNotifier.new);

class SignedInNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void signIn() => state = true;
  void signOut() => state = false;
}

/// The mock candidate's subscription tier. Drives every paywall lock.
enum PlanTier { free, pro, proPlus }

final planTierProvider =
    NotifierProvider<PlanTierNotifier, PlanTier>(PlanTierNotifier.new);

class PlanTierNotifier extends Notifier<PlanTier> {
  @override
  PlanTier build() => PlanTier.free;

  void upgradeTo(PlanTier tier) => state = tier;
}
