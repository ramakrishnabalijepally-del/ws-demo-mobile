/// A job posting.
class Job {
  const Job({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.employment,
    required this.salaryLow,
    required this.salaryHigh,
    required this.category,
    required this.postedAgo,
    required this.permitFriendly,
    required this.nocCode,
    required this.summary,
    required this.requirements,
    this.saved = false,
  });

  final String id;
  final String title;
  final String company;

  /// City, Province.
  final String location;

  final Employment employment;

  /// Annual, in Canadian dollars. A range is honest where a single figure is
  /// not.
  final int salaryLow;
  final int salaryHigh;

  final String category;
  final String postedAgo;

  /// Whether the employer has hired on a work permit before. This is the whole
  /// reason a newcomer opens the app, so it is a first-class field, not a tag.
  final bool permitFriendly;

  /// National Occupational Classification — the code immigration programs
  /// match on.
  final String nocCode;

  final String summary;
  final List<String> requirements;

  final bool saved;

  String get salaryRange => '\$${_k(salaryLow)}–${_k(salaryHigh)}';

  static String _k(int amount) => '${(amount / 1000).round()}k';

  Job copyWith({bool? saved}) => Job(
        id: id,
        title: title,
        company: company,
        location: location,
        employment: employment,
        salaryLow: salaryLow,
        salaryHigh: salaryHigh,
        category: category,
        postedAgo: postedAgo,
        permitFriendly: permitFriendly,
        nocCode: nocCode,
        summary: summary,
        requirements: requirements,
        saved: saved ?? this.saved,
      );
}

enum Employment {
  fullTime('Full-time'),
  partTime('Part-time'),
  contract('Contract'),
  freelance('Freelance'),
  internship('Internship');

  const Employment(this.label);

  final String label;
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
