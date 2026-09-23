import 'crs_profile.dart';
import 'immigration_details.dart';
import 'profile_section.dart';

/// What the candidate is here for, in the order registration offers them.
///
/// Registration asks this on its own step, with a blurb under each option;
/// the profile form asks the same question with the same four answers, so
/// the vocabulary lives here rather than inside either feature.
const List<String> candidateProfileTypes = [
  'Job Seeker',
  'Student',
  'Permanent Residence Applicant',
  'Other',
];

/// Your Goals — multi-select, asked in registration and editable on the
/// profile. Written in the second person, as the voice rules ask.
const List<String> candidateGoals = [
  'Find a job in my field',
  'Apply for permanent residence',
  'Understand which programs I qualify for',
  'Predict my CRS score',
  'Improve my French',
  'Book a consultation with a licensed RCIC',
  'Get my credentials recognised',
  'Settle my family in Canada',
];

/// Job Interests — three to five, asked in registration and editable on the
/// profile.
const List<String> candidateJobCategories = [
  'Design',
  'Content',
  'Marketing',
  'Engineering',
  'Programming',
  'Finance',
  'Human Resources',
  'Customer Service',
  'Healthcare',
  'Education',
  'Trades',
  'Logistics',
  'Hospitality',
  'Accounting',
  'Legal',
  'Sales',
  'Administration',
  'Research',
];

/// How many job interests a candidate picks.
const int minJobCategories = 3;
const int maxJobCategories = 5;

/// The signed-in candidate.
///
/// The candidate is the only role this app builds (`docs/PLAN.md` section 1) —
/// there is no employer, consultant or admin model, and adding one is a scope
/// change, not a refactor.
///
/// **The profile is the base of the app.** Profile strength and the CRS score
/// are both calculated from it rather than stored beside it, so they can never
/// disagree with what the candidate has entered.
class Candidate {
  const Candidate({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.occupation,
    required this.city,
    required this.province,
    required this.countryOfOrigin,
    required this.verified,
    required this.profileType,
    required this.goals,
    required this.jobCategories,
    required this.crs,
    this.immigration = const ImmigrationDetails(),
    this.avatarUrl,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  /// Stored as entered, in the format the form asks for: YYYY-MM-DD.
  final String dateOfBirth;

  final String occupation;
  final String city;
  final String province;
  final String countryOfOrigin;

  final bool verified;

  /// One of [candidateProfileTypes].
  final String profileType;

  final List<String> goals;
  final List<String> jobCategories;

  /// Everything the CRS score is calculated from.
  final CrsProfile crs;

  /// Passport and status in Canada — the immigration profile beyond the CRS.
  final ImmigrationDetails immigration;

  // TODO(assets): the design deck uses photography here. Null renders initials.
  final String? avatarUrl;

  String get fullName => '$firstName $lastName';

  String get initials => '${firstName.isEmpty ? '' : firstName[0]}'
      '${lastName.isEmpty ? '' : lastName[0]}';

  DateTime? get birthDate => DateTime.tryParse(dateOfBirth);

  /// 0–100: how much of the profile the CRS needs has been answered.
  int get profileStrength =>
      completionOf(crs, hasDateOfBirth: birthDate != null).percent;

  Candidate copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? dateOfBirth,
    String? occupation,
    String? city,
    String? province,
    String? countryOfOrigin,
    bool? verified,
    String? profileType,
    List<String>? goals,
    List<String>? jobCategories,
    CrsProfile? crs,
    ImmigrationDetails? immigration,
    String? avatarUrl,
  }) {
    return Candidate(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      occupation: occupation ?? this.occupation,
      city: city ?? this.city,
      province: province ?? this.province,
      countryOfOrigin: countryOfOrigin ?? this.countryOfOrigin,
      verified: verified ?? this.verified,
      profileType: profileType ?? this.profileType,
      goals: goals ?? this.goals,
      jobCategories: jobCategories ?? this.jobCategories,
      crs: crs ?? this.crs,
      immigration: immigration ?? this.immigration,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
