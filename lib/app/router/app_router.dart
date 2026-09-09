import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/assistant/assistant.dart';
import '../../features/auth/auth.dart';
import '../../features/home/home.dart';
import '../../features/immigration/immigration.dart';
import '../../features/jobs/jobs.dart';
import '../../features/onboarding/onboarding.dart';
import '../../features/profile/profile.dart';
import '../../features/registration/registration.dart';
import '../../features/settlement/settlement.dart';
import '../../features/subscription/subscription.dart';
import '../providers.dart';
import 'routes.dart';
import 'shell_scaffold.dart';

/// The router.
///
/// Three layers:
///
/// 1. **Outside the shell** — splash, onboarding, auth and registration. No
///    bottom navigation, because there is nothing to navigate between yet.
/// 2. **The shell** — a `StatefulShellRoute` with five branches, each keeping
///    its own stack, so switching tabs and coming back returns you where you
///    were.
/// 3. **Above the shell** — the assistant and the paywall, pushed full-screen
///    on the root navigator. The assistant because voice mode inverts the whole
///    screen; the paywall because it is reached by touching a locked feature
///    and is never a destination.
final routerProvider = Provider<GoRouter>((ref) {
  final rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: Routes.splash,
    debugLogDiagnostics: false,
    routes: [
      // --- Outside the shell ---------------------------------------------
      GoRoute(
        path: Routes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: Routes.signIn,
        builder: (_, __) => const SignInScreen(),
      ),
      GoRoute(
        path: Routes.signUp,
        builder: (_, __) => const SignUpScreen(),
      ),
      GoRoute(
        path: Routes.forgotPassword,
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: Routes.resetMethod,
        builder: (_, __) => const ResetMethodScreen(),
      ),
      GoRoute(
        path: Routes.accountCreated,
        builder: (_, __) => const AccountCreatedScreen(),
      ),
      GoRoute(
        path: Routes.registration,
        builder: (_, __) => const RegistrationScreen(),
      ),

      // --- Above the shell -----------------------------------------------
      GoRoute(
        path: Routes.assistant,
        parentNavigatorKey: rootKey,
        builder: (_, __) => const AssistantScreen(),
        routes: [
          GoRoute(
            path: 'voice',
            parentNavigatorKey: rootKey,
            builder: (_, __) => const VoiceModeScreen(),
          ),
          GoRoute(
            path: 'saved',
            parentNavigatorKey: rootKey,
            builder: (_, __) => const SavedConversationsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: Routes.paywall,
        parentNavigatorKey: rootKey,
        builder: (_, state) =>
            PaywallScreen(lockedFeature: state.extra as String?),
        routes: [
          GoRoute(
            path: 'plans',
            parentNavigatorKey: rootKey,
            builder: (_, __) => const PlansScreen(),
          ),
          GoRoute(
            path: 'compare',
            parentNavigatorKey: rootKey,
            builder: (_, __) => const PlanComparisonScreen(),
          ),
          GoRoute(
            path: 'payment',
            parentNavigatorKey: rootKey,
            builder: (_, state) => PaymentScreen(
              tier: state.extra as PlanTier? ?? PlanTier.pro,
            ),
          ),
          GoRoute(
            path: 'active',
            parentNavigatorKey: rootKey,
            builder: (_, __) => const SubscriptionActiveScreen(),
          ),
        ],
      ),

      // --- The shell: five branches, five stacks ---------------------------
      StatefulShellRoute.indexedStack(
        builder: (_, __, navigationShell) =>
            ShellScaffold(navigationShell: navigationShell),
        branches: [
          // 1 · Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.home,
                builder: (_, __) => const DashboardScreen(),
                routes: [
                  GoRoute(
                    path: 'notifications',
                    builder: (_, __) => const NotificationsScreen(),
                  ),
                  GoRoute(
                    path: 'tips',
                    builder: (_, __) => const TipsScreen(),
                    routes: [
                      GoRoute(
                        path: ':id',
                        builder: (_, state) => TipArticleScreen(
                          tipId: state.pathParameters['id']!,
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'hub',
                    builder: (_, __) => const FeatureHubScreen(),
                  ),
                ],
              ),
            ],
          ),

          // 2 · Jobs
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.jobs,
                builder: (_, __) => const JobsScreen(),
                routes: [
                  GoRoute(
                    path: 'detail/:id',
                    builder: (_, state) => JobDetailsScreen(
                      jobId: state.pathParameters['id']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'apply',
                        builder: (_, state) => JobApplyScreen(
                          jobId: state.pathParameters['id']!,
                        ),
                        routes: [
                          GoRoute(
                            path: 'result',
                            builder: (_, state) {
                              final jobId = state.pathParameters['id']!;
                              // ?status=failed reaches F6; anything else is F5.
                              return state.uri.queryParameters['status'] ==
                                      'failed'
                                  ? ApplyFailedScreen(jobId: jobId)
                                  : ApplySuccessScreen(jobId: jobId);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'applications',
                    builder: (_, __) => const ApplicationsScreen(),
                    routes: [
                      GoRoute(
                        path: ':id',
                        builder: (_, state) => ApplicationDetailScreen(
                          applicationId: state.pathParameters['id']!,
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'saved',
                    builder: (_, __) => const SavedJobsScreen(),
                  ),
                  GoRoute(
                    path: 'messages',
                    builder: (_, __) => const ChatListScreen(),
                    routes: [
                      GoRoute(
                        path: ':id',
                        builder: (_, state) => ChatThreadScreen(
                          threadId: state.pathParameters['id']!,
                        ),
                        routes: [
                          GoRoute(
                            path: 'call',
                            builder: (_, state) => CallScreen(
                              threadId: state.pathParameters['id']!,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // 3 · Immigration
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.immigration,
                builder: (_, __) => const ImmigrationScreen(),
                routes: [
                  GoRoute(
                    path: 'crs',
                    builder: (_, __) => const CrsOverviewScreen(),
                    routes: [
                      GoRoute(
                        path: 'calculator',
                        builder: (_, __) => const CrsCalculatorScreen(),
                      ),
                      GoRoute(
                        path: 'result',
                        builder: (_, __) => const CrsResultScreen(),
                        routes: [
                          GoRoute(
                            path: 'breakdown',
                            builder: (_, __) => const CrsBreakdownScreen(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'pnp',
                    builder: (_, __) => const PnpProvincesScreen(),
                    routes: [
                      GoRoute(
                        path: ':province',
                        builder: (_, state) => PnpStreamsScreen(
                          provinceCode: state.pathParameters['province']!,
                        ),
                        routes: [
                          GoRoute(
                            path: ':stream',
                            builder: (_, state) => PnpStreamDetailScreen(
                              provinceCode: state.pathParameters['province']!,
                              streamName: state.pathParameters['stream']!,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'programs',
                    builder: (_, __) => const ProgramsScreen(),
                  ),
                  GoRoute(
                    path: 'compare',
                    builder: (_, __) => const CompareScreen(),
                  ),
                ],
              ),
            ],
          ),

          // 4 · Settlement
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.settlement,
                builder: (_, __) => const SettlementScreen(),
                routes: [
                  GoRoute(
                    path: 'checklist',
                    builder: (_, __) => const ChecklistScreen(),
                  ),
                  GoRoute(
                    path: 'appointments',
                    builder: (_, __) => const AppointmentsScreen(),
                    routes: [
                      GoRoute(
                        path: 'booked',
                        builder: (_, __) => const AppointmentBookedScreen(),
                      ),
                      GoRoute(
                        path: ':id',
                        builder: (_, state) => AppointmentDetailScreen(
                          consultationId: state.pathParameters['id']!,
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'resources',
                    builder: (_, __) => const ResourcesScreen(),
                  ),
                ],
              ),
            ],
          ),

          // 5 · Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.profile,
                builder: (_, __) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (_, __) => const ProfileEditScreen(),
                  ),
                  GoRoute(
                    path: 'settings',
                    builder: (_, __) => const SettingsScreen(),
                    routes: [
                      GoRoute(
                        path: 'notifications',
                        builder: (_, __) => const NotificationSettingsScreen(),
                      ),
                      GoRoute(
                        path: 'security',
                        builder: (_, __) => const SecuritySettingsScreen(),
                      ),
                      GoRoute(
                        path: 'appearance',
                        builder: (_, __) => const AppearanceSettingsScreen(),
                      ),
                      GoRoute(
                        path: 'help',
                        builder: (_, __) => const HelpScreen(),
                        routes: [
                          GoRoute(
                            path: 'faq',
                            builder: (_, __) => const FaqScreen(),
                          ),
                          GoRoute(
                            path: 'terms',
                            builder: (_, __) => const LegalScreen.terms(),
                          ),
                          GoRoute(
                            path: 'privacy',
                            builder: (_, __) => const LegalScreen.privacy(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],

    // A route that does not exist is a bug, not a user error — say so plainly
    // and give them a way back rather than a stack trace.
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('WorkSettle')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.explore_off_outlined, size: 48),
              const SizedBox(height: 16),
              Text(
                'That screen does not exist',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                state.uri.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go(Routes.home),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
});
