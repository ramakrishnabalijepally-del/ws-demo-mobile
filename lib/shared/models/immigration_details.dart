/// The immigration half of the candidate profile that the CRS does not score:
/// passport and status in Canada.
///
/// Family in Canada lives on `CrsProfile.familyInCanada` instead, because a
/// sibling there is worth CRS points — one answer, read by both.
///
/// Dates are stored as entered, YYYY-MM-DD, like the date of birth. An empty
/// string means not answered.
library;

enum CanadianStatus {
  workPermit('Work permit'),
  visitor('Visitor'),
  studyPermit('Study permit'),
  visitorRecord('Visitor record'),
  restoration('Restoration');

  const CanadianStatus(this.label);

  final String label;
}

class ImmigrationDetails {
  const ImmigrationDetails({
    this.passportNumber = '',
    this.passportIssueDate = '',
    this.passportExpiryDate = '',
    this.status,
    this.statusIssueDate = '',
    this.statusExpiryDate = '',
  });

  // TODO(backend): a passport number is sensitive. The real app encrypts it at
  // rest and only ever shows the last four characters.
  final String passportNumber;
  final String passportIssueDate;
  final String passportExpiryDate;

  /// Null when the candidate has no status in Canada yet.
  final CanadianStatus? status;
  final String statusIssueDate;
  final String statusExpiryDate;

  DateTime? get passportExpiry => DateTime.tryParse(passportExpiryDate);
  DateTime? get statusExpiry => DateTime.tryParse(statusExpiryDate);

  /// "•••• 4821": enough to recognise, not enough to copy.
  String get maskedPassportNumber {
    final n = passportNumber.trim();
    if (n.isEmpty) return '';
    if (n.length <= 4) return n;
    return '•••• ${n.substring(n.length - 4)}';
  }

  static const Object _unset = Object();

  ImmigrationDetails copyWith({
    String? passportNumber,
    String? passportIssueDate,
    String? passportExpiryDate,
    Object? status = _unset,
    String? statusIssueDate,
    String? statusExpiryDate,
  }) {
    return ImmigrationDetails(
      passportNumber: passportNumber ?? this.passportNumber,
      passportIssueDate: passportIssueDate ?? this.passportIssueDate,
      passportExpiryDate: passportExpiryDate ?? this.passportExpiryDate,
      status:
          identical(status, _unset) ? this.status : status as CanadianStatus?,
      statusIssueDate: statusIssueDate ?? this.statusIssueDate,
      statusExpiryDate: statusExpiryDate ?? this.statusExpiryDate,
    );
  }
}

/// "in 4 months", "in 12 days", "3 months ago". For expiry lines.
String relativeToToday(DateTime date, DateTime today) {
  final days = DateTime(date.year, date.month, date.day)
      .difference(DateTime(today.year, today.month, today.day))
      .inDays;
  final ago = days < 0;
  final n = days.abs();
  final String span;
  if (n < 45) {
    span = n == 1 ? '1 day' : '$n days';
  } else if (n < 730) {
    final months = (n / 30.4).round();
    span = '$months months';
  } else {
    span = '${(n / 365.25).floor()} years';
  }
  if (n == 0) return 'today';
  return ago ? '$span ago' : 'in $span';
}
