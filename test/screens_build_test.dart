import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worksettle_mobile/app/providers.dart';
import 'package:worksettle_mobile/app/theme/theme.dart';
import 'package:worksettle_mobile/features/assistant/assistant.dart';
import 'package:worksettle_mobile/features/auth/auth.dart';
import 'package:worksettle_mobile/features/home/home.dart';
import 'package:worksettle_mobile/features/immigration/immigration.dart';
import 'package:worksettle_mobile/features/jobs/jobs.dart';
import 'package:worksettle_mobile/features/onboarding/onboarding.dart';
import 'package:worksettle_mobile/features/profile/profile.dart';
import 'package:worksettle_mobile/features/registration/registration.dart';
import 'package:worksettle_mobile/features/settlement/settlement.dart';
import 'package:worksettle_mobile/features/subscription/subscription.dart';

/// The one test that earns its place in a mock UI: **does every screen build
/// on a small phone, in both themes, without overflowing?**
///
/// An overflow at 360 dp is a failed screen, not a warning
/// (`.agents/rules/03-styling.md` rule 7). A coverage number would tell us
/// less.
///
/// Deliberately no assertions on pixel values or colours — those would codify
/// exactly what the styling rules forbid.
void main() {
  /// The small phone the design system designs for first.
  const smallPhone = Size(360, 800);

  Widget host(Widget child, ThemeMode mode) {
    return ProviderScope(
      child: MaterialApp(
        theme: WorkSettleTheme.light,
        darkTheme: WorkSettleTheme.dark,
        themeMode: mode,
        home: child,
      ),
    );
  }

  final screens = <String, Widget Function()>{
    // Launch and auth
    'Onboarding': OnboardingScreen.new,
    'Sign in': SignInScreen.new,
    'Sign up': SignUpScreen.new,
    'Forgot password': ForgotPasswordScreen.new,
    'Reset method': ResetMethodScreen.new,
    'Account created': AccountCreatedScreen.new,
    'Registration': RegistrationScreen.new,

    // Home
    'Dashboard': DashboardScreen.new,
    'Notifications': NotificationsScreen.new,
    'Tips': TipsScreen.new,
    'Tip article': () => const TipArticleScreen(tipId: 't1'),
    'Feature hub': FeatureHubScreen.new,

    // Jobs
    'Jobs': JobsScreen.new,
    'Job details': () => const JobDetailsScreen(jobId: 'j1'),
    'Job apply': () => const JobApplyScreen(jobId: 'j1'),
    'Apply success': () => const ApplySuccessScreen(jobId: 'j1'),
    'Apply failed': () => const ApplyFailedScreen(jobId: 'j1'),
    'Applications': ApplicationsScreen.new,
    'Application detail': () =>
        const ApplicationDetailScreen(applicationId: 'a1'),
    'Saved jobs': SavedJobsScreen.new,
    'Chat list': ChatListScreen.new,
    'Chat thread': () => const ChatThreadScreen(threadId: 'c1'),
    'Call': () => const CallScreen(threadId: 'c1'),

    // Immigration
    'Immigration': ImmigrationScreen.new,
    'CRS overview': CrsOverviewScreen.new,
    'CRS calculator': CrsCalculatorScreen.new,
    'CRS result': CrsResultScreen.new,
    'CRS breakdown': CrsBreakdownScreen.new,
    'PNP provinces': PnpProvincesScreen.new,
    'PNP streams': () => const PnpStreamsScreen(provinceCode: 'ON'),
    'PNP stream detail': () => const PnpStreamDetailScreen(
          provinceCode: 'ON',
          streamName: 'Human Capital Priorities',
        ),
    'Programs': ProgramsScreen.new,
    'Compare': CompareScreen.new,

    // Settlement
    'Settlement': SettlementScreen.new,
    'Checklist': ChecklistScreen.new,
    'Appointments': AppointmentsScreen.new,
    'Appointment detail': () =>
        const AppointmentDetailScreen(consultationId: 'c1'),
    'Appointment booked': AppointmentBookedScreen.new,
    'Resources': ResourcesScreen.new,

    // Assistant
    'Assistant': AssistantScreen.new,
    'Voice mode': VoiceModeScreen.new,
    'Saved conversations': SavedConversationsScreen.new,

    // Profile
    'Profile': ProfileScreen.new,
    'Profile edit': ProfileEditScreen.new,
    'Settings': SettingsScreen.new,
    'Notification settings': NotificationSettingsScreen.new,
    'Security settings': SecuritySettingsScreen.new,
    'Appearance settings': AppearanceSettingsScreen.new,
    'Help': HelpScreen.new,
    'FAQ': FaqScreen.new,
    'Terms': LegalScreen.terms,
    'Privacy': LegalScreen.privacy,

    // Subscription
    'Paywall': PaywallScreen.new,
    'Plans': PlansScreen.new,
    'Plan comparison': PlanComparisonScreen.new,
    'Payment': () => const PaymentScreen(tier: PlanTier.pro),
    'Subscription active': SubscriptionActiveScreen.new,
  };

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    final label = mode == ThemeMode.light ? 'light' : 'dark';

    group('$label theme', () {
      for (final entry in screens.entries) {
        testWidgets('${entry.key} builds at 360 dp', (tester) async {
          tester.view.physicalSize = smallPhone;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);

          await tester.pumpWidget(host(entry.value(), mode));
          await tester.pump(const Duration(milliseconds: 100));

          expect(tester.takeException(), isNull);
        });
      }
    });
  }

  testWidgets('text scales to 200% without throwing', (tester) async {
    tester.view.physicalSize = smallPhone;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: WorkSettleTheme.light,
          home: const MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(2.0)),
            child: DashboardScreen(),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);
  });
}
