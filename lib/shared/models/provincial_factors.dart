/// The answers the provincial points grids score and the rest of the profile
/// does not ask: family, work and study in a province, and a job offer.
///
/// Grids checked September 2026: AAIP Worker EOI (Alberta), BC PNP SIRS,
/// SINP International Skilled Worker (Saskatchewan) and MPNP Skilled Worker
/// EOI (Manitoba). See `lib/shared/utils/pnp_calculator.dart`.
library;

/// A province, for the provincial grids. Only the four with a grid are named;
/// every other province or territory is [elsewhere].
enum ProvinceTie {
  alberta('Alberta', 'AB'),
  britishColumbia('British Columbia', 'BC'),
  saskatchewan('Saskatchewan', 'SK'),
  manitoba('Manitoba', 'MB'),
  elsewhere('Another province or territory', null),
  none('None', null);

  const ProvinceTie(this.label, this.code);

  final String label;

  /// The two-letter code the routes and flags use; null for the catch-alls.
  final String? code;

  /// The four provinces with a points grid, in the order they are shown.
  static const List<ProvinceTie> scored = [
    alberta,
    britishColumbia,
    saskatchewan,
    manitoba,
  ];

  static ProvinceTie? forCode(String code) {
    for (final tie in scored) {
      if (tie.code == code.toUpperCase()) return tie;
    }
    return null;
  }
}

/// Where in British Columbia a job is — the SIRS area of employment.
enum BcArea {
  metroVancouver('Metro Vancouver'),
  area2('Squamish, Abbotsford, Agassiz, Mission or Chilliwack'),
  elsewhere('Anywhere else in British Columbia');

  const BcArea(this.label);

  final String label;
}

class ProvincialFactors {
  const ProvincialFactors({
    this.immediateFamily,
    this.extendedFamily,
    this.workedIn,
    this.saskatchewanWorkYear,
    this.studiedIn,
    this.manitobaStudyTwoYears,
    this.jobOffer,
    this.albertaJobOutsideCities,
    this.albertaJobRegulated,
    this.bcHourlyWage,
    this.bcArea,
    this.workingForEmployer,
    this.answeredFor = const {},
  });

  /// Where a parent, brother, sister or child lives — 18 or older, citizen or
  /// permanent resident. Alberta counts only these; Saskatchewan and Manitoba
  /// count them too. An empty set is "none of these"; null is unanswered.
  final Set<ProvinceTie>? immediateFamily;

  /// Where a grandparent, aunt, uncle, niece, nephew or cousin lives —
  /// counted by Saskatchewan and Manitoba, not Alberta.
  final Set<ProvinceTie>? extendedFamily;

  /// Where the candidate has worked full time for six months or more.
  final Set<ProvinceTie>? workedIn;

  /// Saskatchewan scores past work there only at 12 months or more within the
  /// last five years. Asked only when [workedIn] includes Saskatchewan.
  final bool? saskatchewanWorkYear;

  /// Where the candidate completed a post-secondary program. Not asked when
  /// the profile says there is no Canadian post-secondary education.
  final Set<ProvinceTie>? studiedIn;

  /// Manitoba scores a two-year program at 100 and a one-year at 50. Asked
  /// only when [studiedIn] includes Manitoba.
  final bool? manitobaStudyTwoYears;

  /// A full-time, permanent job offer, in one of the four grid provinces, or
  /// [ProvinceTie.none].
  final ProvinceTie? jobOffer;

  final bool? albertaJobOutsideCities;
  final bool? albertaJobRegulated;
  final double? bcHourlyWage;
  final BcArea? bcArea;

  /// Working full time for the offering employer now — BC +10, and with six
  /// months or more in Manitoba, Manitoba's 500-point demand factor.
  final bool? workingForEmployer;

  /// The provinces whose own questions have been answered and saved.
  ///
  /// Each province is scored on its own, so each asks only what its grid
  /// reads. Answering Alberta's questions says nothing about Manitoba's, so
  /// the sets above cannot tell on their own which provinces are done.
  final Set<ProvinceTie> answeredFor;

  bool isAnsweredFor(ProvinceTie province) => answeredFor.contains(province);

  static const Object _unset = Object();

  /// Pass `null` explicitly to clear an answer; omit a field to keep it.
  ProvincialFactors copyWith({
    Object? immediateFamily = _unset,
    Object? extendedFamily = _unset,
    Object? workedIn = _unset,
    Object? saskatchewanWorkYear = _unset,
    Object? studiedIn = _unset,
    Object? manitobaStudyTwoYears = _unset,
    Object? jobOffer = _unset,
    Object? albertaJobOutsideCities = _unset,
    Object? albertaJobRegulated = _unset,
    Object? bcHourlyWage = _unset,
    Object? bcArea = _unset,
    Object? workingForEmployer = _unset,
    Set<ProvinceTie>? answeredFor,
  }) {
    T? pick<T>(Object? next, T? current) =>
        identical(next, _unset) ? current : next as T?;

    return ProvincialFactors(
      immediateFamily: pick(immediateFamily, this.immediateFamily),
      extendedFamily: pick(extendedFamily, this.extendedFamily),
      workedIn: pick(workedIn, this.workedIn),
      saskatchewanWorkYear:
          pick(saskatchewanWorkYear, this.saskatchewanWorkYear),
      studiedIn: pick(studiedIn, this.studiedIn),
      manitobaStudyTwoYears:
          pick(manitobaStudyTwoYears, this.manitobaStudyTwoYears),
      jobOffer: pick(jobOffer, this.jobOffer),
      albertaJobOutsideCities:
          pick(albertaJobOutsideCities, this.albertaJobOutsideCities),
      albertaJobRegulated: pick(albertaJobRegulated, this.albertaJobRegulated),
      bcHourlyWage: pick(bcHourlyWage, this.bcHourlyWage),
      bcArea: pick(bcArea, this.bcArea),
      workingForEmployer: pick(workingForEmployer, this.workingForEmployer),
      answeredFor: answeredFor ?? this.answeredFor,
    );
  }
}
