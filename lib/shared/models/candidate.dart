/// The signed-in candidate.
///
/// The candidate is the only role this app builds (`docs/PLAN.md` section 1) —
/// there is no employer, consultant or admin model, and adding one is a scope
/// change, not a refactor.
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
    required this.profileStrength,
    required this.verified,
    required this.profileType,
    required this.goals,
    required this.jobCategories,
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

  /// 0–100. Rendered by the one ring in the product.
  final int profileStrength;

  final bool verified;

  /// Job Seeker · Student · Other.
  final String profileType;

  final List<String> goals;
  final List<String> jobCategories;

  // TODO(assets): the design deck uses photography here. Null renders initials.
  final String? avatarUrl;

  String get fullName => '$firstName $lastName';

  String get initials => '${firstName.isEmpty ? '' : firstName[0]}'
      '${lastName.isEmpty ? '' : lastName[0]}';

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
    int? profileStrength,
    bool? verified,
    String? profileType,
    List<String>? goals,
    List<String>? jobCategories,
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
      profileStrength: profileStrength ?? this.profileStrength,
      verified: verified ?? this.verified,
      profileType: profileType ?? this.profileType,
      goals: goals ?? this.goals,
      jobCategories: jobCategories ?? this.jobCategories,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
