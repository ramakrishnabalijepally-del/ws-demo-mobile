import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The six registration steps. `design/worksettle-design-system.md` Pattern A:
/// **one decision per screen, a segment bar throughout, and a review screen
/// before anything is committed.**
enum RegistrationStep {
  basicInfo('Basic Information'),
  contact('Contact Information'),
  profileType('Profile Type'),
  goals('Your Goals'),
  jobCategories('Job Interests'),
  review('Almost There');

  const RegistrationStep(this.title);

  final String title;
}

/// What the candidate has entered so far.
class RegistrationDraft {
  const RegistrationDraft({
    this.firstName = '',
    this.lastName = '',
    this.dateOfBirth = '',
    this.countryOfOrigin = '',
    this.email = '',
    this.phone = '',
    this.city = '',
    this.province = '',
    this.profileType = '',
    this.goals = const [],
    this.jobCategories = const [],
  });

  final String firstName;
  final String lastName;
  final String dateOfBirth;
  final String countryOfOrigin;
  final String email;
  final String phone;
  final String city;
  final String province;
  final String profileType;
  final List<String> goals;
  final List<String> jobCategories;

  RegistrationDraft copyWith({
    String? firstName,
    String? lastName,
    String? dateOfBirth,
    String? countryOfOrigin,
    String? email,
    String? phone,
    String? city,
    String? province,
    String? profileType,
    List<String>? goals,
    List<String>? jobCategories,
  }) {
    return RegistrationDraft(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      countryOfOrigin: countryOfOrigin ?? this.countryOfOrigin,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      province: province ?? this.province,
      profileType: profileType ?? this.profileType,
      goals: goals ?? this.goals,
      jobCategories: jobCategories ?? this.jobCategories,
    );
  }
}

class RegistrationState {
  const RegistrationState({
    this.step = RegistrationStep.basicInfo,
    this.draft = const RegistrationDraft(),
  });

  final RegistrationStep step;
  final RegistrationDraft draft;

  int get stepNumber => step.index + 1;
  int get totalSteps => RegistrationStep.values.length;

  RegistrationState copyWith({
    RegistrationStep? step,
    RegistrationDraft? draft,
  }) {
    return RegistrationState(
      step: step ?? this.step,
      draft: draft ?? this.draft,
    );
  }
}

final registrationProvider =
    NotifierProvider<RegistrationController, RegistrationState>(
  RegistrationController.new,
);

class RegistrationController extends Notifier<RegistrationState> {
  @override
  RegistrationState build() => const RegistrationState();

  void next() {
    final i = state.step.index;
    if (i < RegistrationStep.values.length - 1) {
      state = state.copyWith(step: RegistrationStep.values[i + 1]);
    }
  }

  void back() {
    final i = state.step.index;
    if (i > 0) state = state.copyWith(step: RegistrationStep.values[i - 1]);
  }

  /// The review screen's inline Edit links jump straight to a step. **The user
  /// never has to walk the whole flow again to change one answer** (Pattern A).
  void goTo(RegistrationStep step) => state = state.copyWith(step: step);

  void update(RegistrationDraft draft) => state = state.copyWith(draft: draft);

  void toggleGoal(String goal) {
    final goals = [...state.draft.goals];
    goals.contains(goal) ? goals.remove(goal) : goals.add(goal);
    update(state.draft.copyWith(goals: goals));
  }

  void toggleCategory(String category) {
    final categories = [...state.draft.jobCategories];
    categories.contains(category)
        ? categories.remove(category)
        : categories.add(category);
    update(state.draft.copyWith(jobCategories: categories));
  }
}
