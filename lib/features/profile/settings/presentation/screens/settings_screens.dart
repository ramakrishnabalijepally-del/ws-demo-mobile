import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/providers.dart';
import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/theme.dart';
import '../../../../../shared/shared.dart';

/// N1 — settings.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          WsSpacing.xl,
          WsSpacing.lg,
          WsSpacing.xl,
          WsSpacing.xxxl,
        ),
        children: [
          WsCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                WsListRow(
                  leading: const WsIconTile(
                    icon: Icons.notifications_none_rounded,
                  ),
                  title: 'Notifications',
                  onTap: () => context.push(Routes.settingsNotifications),
                ),
                Divider(color: context.colors.outlineVariant, height: 1),
                WsListRow(
                  leading: const WsIconTile(icon: Icons.lock_outline_rounded),
                  title: 'Security',
                  onTap: () => context.push(Routes.settingsSecurity),
                ),
                Divider(color: context.colors.outlineVariant, height: 1),
                WsListRow(
                  leading: const WsIconTile(
                    icon: Icons.brightness_6_outlined,
                  ),
                  title: 'Appearance',
                  onTap: () => context.push(Routes.settingsAppearance),
                ),
                Divider(color: context.colors.outlineVariant, height: 1),
                WsListRow(
                  leading: const WsIconTile(icon: Icons.help_outline_rounded),
                  title: 'Help',
                  onTap: () => context.push(Routes.help),
                ),
              ],
            ),
          ),
          const SizedBox(height: WsSpacing.md),
          WsCard(
            padding: EdgeInsets.zero,
            child: WsListRow(
              leading: const WsIconTile(icon: Icons.workspace_premium_outlined),
              title: 'Your plan',
              subtitle: switch (ref.watch(planTierProvider)) {
                PlanTier.free => 'Free — basic profile and job search',
                PlanTier.pro => 'Pro — \$10 a month',
                PlanTier.proPlus => 'Pro+ — \$50 a month',
              },
              onTap: () => context.push(Routes.plans),
            ),
          ),
          const SizedBox(height: WsSpacing.xxl),
          WsSecondaryButton(
            label: 'Log out',
            icon: Icons.logout_rounded,
            onPressed: () => _confirmLogout(context, ref),
          ),
        ],
      ),
    );
  }

  /// N9 — the logout sheet.
  static Future<void> _confirmLogout(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            WsSpacing.xl,
            WsSpacing.sm,
            WsSpacing.xl,
            WsSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: WsIconTile(
                  icon: Icons.logout_rounded,
                  size: WsTileSize.header,
                ),
              ),
              const SizedBox(height: WsSpacing.xl),
              Text(
                'Log out of WorkSettle?',
                style: context.text.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: WsSpacing.sm),
              Text(
                'Your profile and documents stay exactly as they are. You will '
                'need your password to get back in.',
                style: context.text.bodyMedium
                    ?.copyWith(color: context.colors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: WsSpacing.xxl),
              WsPrimaryButton(
                label: 'Log out',
                forward: false,
                onPressed: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(height: WsSpacing.md),
              WsGhostButton(
                label: 'Stay signed in',
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed ?? false) {
      ref.read(signedInProvider.notifier).signOut();
      if (context.mounted) context.go(Routes.signIn);
    }
  }
}

/// N2 — notification toggles.
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final Map<String, bool> _values = {
    'Application updates': true,
    'New job matches': true,
    'Express Entry draw results': true,
    'Checklist reminders': false,
    'Appointment reminders': true,
    'Product news': false,
  };

  @override
  Widget build(BuildContext context) {
    return _ToggleList(
      title: 'Notifications',
      // TODO(backend): nothing is scheduled or delivered; these are in-memory.
      subtitle: 'Choose what WorkSettle tells you about.',
      values: _values,
      onChanged: (key, value) => setState(() => _values[key] = value),
    );
  }
}

/// N3 — security toggles.
class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  final Map<String, bool> _values = {
    'Unlock with biometrics': true,
    'Stay signed in on this device': true,
    'Require a code for payments': false,
  };

  @override
  Widget build(BuildContext context) {
    return _ToggleList(
      title: 'Security',
      // TODO(backend): no biometric or session handling in the mock.
      subtitle: 'How you get into your account on this device.',
      values: _values,
      onChanged: (key, value) => setState(() => _values[key] = value),
    );
  }
}

/// N4 — Appearance.
///
/// **Dark Mode here drives the real `themeMode`** — it is the one settings
/// toggle in the app that is not a mock.
class AppearanceSettingsScreen extends ConsumerWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(themeModeProvider.notifier);
    final mode = ref.watch(themeModeProvider);
    final isDark = switch (mode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system =>
        MediaQuery.platformBrightnessOf(context) == Brightness.dark,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Appearance')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          WsSpacing.xl,
          WsSpacing.lg,
          WsSpacing.xl,
          WsSpacing.xxxl,
        ),
        children: [
          Text(
            'Dark is a full second theme, not a filter — the whole ramp '
            'inverts. The brand red stays exactly as it is.',
            style: context.text.bodyMedium
                ?.copyWith(color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: WsSpacing.xl),
          WsCard(
            padding: const EdgeInsets.symmetric(
              horizontal: WsSpacing.lg,
              vertical: WsSpacing.xs,
            ),
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: isDark,
                  onChanged: notifier.setDark,
                  title: Text('Dark mode', style: context.text.bodyMedium),
                  subtitle: Text(
                    mode == ThemeMode.system
                        ? 'Following your device right now'
                        : 'Set by you',
                    style: context.text.bodySmall
                        ?.copyWith(color: context.ws.caption),
                  ),
                ),
                Divider(color: context.colors.outlineVariant, height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Follow my device',
                    style: context.text.bodyMedium,
                  ),
                  trailing: mode == ThemeMode.system
                      ? Icon(
                          Icons.check_rounded,
                          color: context.colors.primary,
                          semanticLabel: 'Selected',
                        )
                      : null,
                  onTap: notifier.followSystem,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleList extends StatelessWidget {
  const _ToggleList({
    required this.title,
    required this.subtitle,
    required this.values,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final Map<String, bool> values;
  final void Function(String key, bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    final keys = values.keys.toList();

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          WsSpacing.xl,
          WsSpacing.lg,
          WsSpacing.xl,
          WsSpacing.xxxl,
        ),
        children: [
          Text(
            subtitle,
            style: context.text.bodyMedium
                ?.copyWith(color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: WsSpacing.xl),
          WsCard(
            padding: const EdgeInsets.symmetric(
              horizontal: WsSpacing.lg,
              vertical: WsSpacing.xs,
            ),
            child: Column(
              children: [
                for (var i = 0; i < keys.length; i++) ...[
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: values[keys[i]]!,
                    onChanged: (v) => onChanged(keys[i], v),
                    title: Text(keys[i], style: context.text.bodyMedium),
                  ),
                  if (i != keys.length - 1)
                    Divider(color: context.colors.outlineVariant, height: 1),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
