/// Every route path in the app, in one place.
///
/// Features export their screens; they do not define global routes
/// (`.agents/rules/02-structure.md` rule 7).
abstract final class Routes {
  // --- Outside the shell -----------------------------------------------------
  static const String splash = '/';
  static const String onboarding = '/onboarding';

  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String forgotPassword = '/forgot-password';
  static const String resetMethod = '/forgot-password/method';
  static const String accountCreated = '/account-created';

  static const String registration = '/registration';

  /// The assistant is a full surface of its own, and voice mode inverts the
  /// whole screen — so it sits above the shell, not inside a tab.
  static const String assistant = '/assistant';
  static const String assistantVoice = '/assistant/voice';
  static const String assistantSaved = '/assistant/saved';

  /// Reached only by touching a locked feature. **Never a nav destination.**
  static const String paywall = '/upgrade';
  static const String plans = '/upgrade/plans';
  static const String planComparison = '/upgrade/compare';
  static const String payment = '/upgrade/payment';
  static const String subscriptionActive = '/upgrade/active';

  // --- Shell branch 1 · Home -------------------------------------------------
  static const String home = '/home';
  static const String notifications = '/home/notifications';
  static const String tips = '/home/tips';
  static const String tipArticle = '/home/tips/:id';
  static const String featureHub = '/home/hub';

  // --- Shell branch 2 · Jobs -------------------------------------------------
  static const String jobs = '/jobs';
  static const String jobSearch = '/jobs/search';
  static const String jobFilterFields = '/jobs/search/fields';
  static const String jobDetails = '/jobs/detail/:id';
  static const String jobApply = '/jobs/detail/:id/apply';
  static const String jobApplyResult = '/jobs/detail/:id/apply/result';
  static const String applications = '/jobs/applications';
  static const String applicationDetail = '/jobs/applications/:id';
  static const String savedJobs = '/jobs/saved';
  static const String chatList = '/jobs/messages';
  static const String chatThread = '/jobs/messages/:id';
  static const String call = '/jobs/messages/:id/call';

  // --- Shell branch 3 · Immigration ------------------------------------------
  static const String immigration = '/immigration';
  static const String crsOverview = '/immigration/crs';
  static const String crsCalculator = '/immigration/crs/calculator';
  static const String crsResult = '/immigration/crs/result';
  static const String crsBreakdown = '/immigration/crs/result/breakdown';
  static const String pnpProvinces = '/immigration/pnp';
  static const String pnpStreams = '/immigration/pnp/:province';
  static const String pnpEligibility = '/immigration/pnp/:province/:stream';
  static const String pnpResult = '/immigration/pnp/:province/:stream/result';
  static const String programs = '/immigration/programs';
  static const String compare = '/immigration/compare';

  // --- Shell branch 4 · Settlement -------------------------------------------
  static const String settlement = '/settlement';
  static const String checklist = '/settlement/checklist';
  static const String appointments = '/settlement/appointments';
  static const String appointmentDetail = '/settlement/appointments/:id';
  static const String appointmentBooked = '/settlement/appointments/booked';
  static const String resources = '/settlement/resources';

  // --- Shell branch 5 · Profile ----------------------------------------------
  static const String profile = '/profile';
  static const String profileEdit = '/profile/edit';
  static const String documents = '/profile/documents';
  static const String goals = '/profile/goals';
  static const String settings = '/profile/settings';
  static const String settingsNotifications = '/profile/settings/notifications';
  static const String settingsSecurity = '/profile/settings/security';
  static const String settingsAppearance = '/profile/settings/appearance';
  static const String help = '/profile/settings/help';
  static const String faq = '/profile/settings/help/faq';
  static const String terms = '/profile/settings/help/terms';
  static const String privacy = '/profile/settings/help/privacy';

  /// Build a concrete path from a parameterised one.
  static String withId(String template, String id) =>
      template.replaceFirst(RegExp(r':\w+'), id);
}
