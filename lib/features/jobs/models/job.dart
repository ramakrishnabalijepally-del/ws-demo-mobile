import 'package:flutter/material.dart';

/// A job posting.
class Job {
  const Job({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.types,
    required this.salaryLow,
    required this.salaryHigh,
    required this.category,
    required this.postedHoursAgo,
    required this.searchCount,
    required this.permitFriendly,
    required this.nocCode,
    required this.summary,
    required this.description,
    required this.duties,
    required this.experience,
    required this.education,
    required this.certifications,
    required this.skills,
    required this.benefits,
    required this.immigrationSupport,
    this.saved = false,
  });

  final String id;
  final String title;
  final String company;

  /// City, Province.
  final String location;

  /// Schedule and term together, such as Full-time and Permanent. A posting is
  /// usually one of each, so this is a list rather than a single value.
  final List<Employment> types;

  /// Annual, in Canadian dollars. A range is honest where a single figure is
  /// not.
  final int salaryLow;
  final int salaryHigh;

  final String category;

  /// Hours since the posting went live. Drives both the "posted" line and the
  /// New badge.
  final int postedHoursAgo;

  /// How often the role was searched for in the last 30 days. Ranks the Most
  /// searched bar.
  // TODO(backend): a real count from search analytics.
  final int searchCount;

  /// Whether the employer has hired on a work permit before. This is the whole
  /// reason a newcomer opens the app, so it is a first-class field, not a tag.
  final bool permitFriendly;

  /// National Occupational Classification — the code immigration programs
  /// match on.
  final String nocCode;

  /// One line, shown as the lead of the description.
  final String summary;

  /// The full job description, one entry per paragraph: the employer, the
  /// team and what the role is really like.
  final List<String> description;

  /// Tasks and duties, most time-consuming first.
  final List<String> duties;

  final String experience;
  final String education;

  /// Licences and certifications. Empty means none are required.
  final List<String> certifications;

  final List<String> skills;
  final Set<JobBenefit> benefits;
  final Set<ImmigrationSupport> immigrationSupport;

  final bool saved;

  /// How long a posting keeps its New badge.
  static const int newForHours = 48;

  bool get isNew => postedHoursAgo <= newForHours;

  String get salaryRange => '\$${_k(salaryLow)}–${_k(salaryHigh)}';

  /// "Full-time · Permanent".
  String get typeLabel => types.map((t) => t.label).join(' · ');

  String get postedAgo {
    final h = postedHoursAgo;
    if (h < 1) return 'just now';
    if (h < 24) return h == 1 ? '1 hour ago' : '$h hours ago';
    if (h < 48) return 'yesterday';
    final days = h ~/ 24;
    if (days < 7) return '$days days ago';
    final weeks = days ~/ 7;
    return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
  }

  static String _k(int amount) => '${(amount / 1000).round()}k';

  Job copyWith({bool? saved}) => Job(
        id: id,
        title: title,
        company: company,
        location: location,
        types: types,
        salaryLow: salaryLow,
        salaryHigh: salaryHigh,
        category: category,
        postedHoursAgo: postedHoursAgo,
        searchCount: searchCount,
        permitFriendly: permitFriendly,
        nocCode: nocCode,
        summary: summary,
        description: description,
        duties: duties,
        experience: experience,
        education: education,
        certifications: certifications,
        skills: skills,
        benefits: benefits,
        immigrationSupport: immigrationSupport,
        saved: saved ?? this.saved,
      );
}

/// Job type. Full-time and Part-time say how many hours; Seasonal, Temporary
/// and Permanent say for how long.
enum Employment {
  fullTime('Full-time'),
  partTime('Part-time'),
  seasonal('Seasonal'),
  temporary('Temporary'),
  permanent('Permanent');

  const Employment(this.label);

  final String label;
}

/// The benefits every posting is checked against. The details screen lists
/// all five, so a benefit that is not offered reads as not offered, rather
/// than as something the posting forgot to mention.
enum JobBenefit {
  accommodation('Accommodation', Icons.home_outlined),
  healthInsurance('Health insurance', Icons.health_and_safety_outlined),
  travelExpenses('Travel expenses', Icons.flight_outlined),
  bonus('Bonus', Icons.card_giftcard_outlined),
  overtime('Overtime pay', Icons.more_time_outlined);

  const JobBenefit(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// What the employer will do toward the candidate's immigration.
enum ImmigrationSupport {
  pnp('PNP', 'Supports a Provincial Nominee Program application'),
  lmia('LMIA', 'Will apply for a Labour Market Impact Assessment'),
  jobOffer('Job offer', 'Provides a written offer for your application');

  const ImmigrationSupport(this.label, this.detail);

  final String label;
  final String detail;
}

/// Where an application has got to.
///
/// The deck colours these green, amber and red. **None of that survives**: red
/// is brand and action only, and an immigration-adjacent product that flashes
/// red at people reads as rejection (design system section 2). Each status maps
/// onto the three-rung filled/outlined/tinted ladder instead.
enum ApplicationStatus {
  submitted('Submitted'),
  underReview('Under Review'),
  interview('Interview Scheduled'),
  offer('Offer'),
  notSelected('Not Selected');

  const ApplicationStatus(this.label);

  final String label;
}

class JobApplication {
  const JobApplication({
    required this.id,
    required this.job,
    required this.status,
    required this.appliedOn,
    required this.message,
    this.interviewOn,
  });

  final String id;
  final Job job;
  final ApplicationStatus status;
  final String appliedOn;

  /// The letter from the employer, shown on the detail screen.
  final String message;

  final String? interviewOn;
}
