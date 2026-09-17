import 'package:flutter/material.dart';

import 'crs_profile.dart';

/// The sections of the candidate profile the CRS score is built from.
///
/// **The profile is the base of the whole app**: the CRS score, eligibility and
/// job matches are all calculated from it, so completion is measured against
/// exactly these sections.
enum ProfileSection {
  aboutYou(
    'About you',
    'Your date of birth and marital status',
    Icons.person_outline_rounded,
  ),
  education(
    'Education',
    'Your highest qualification, and any study in Canada',
    Icons.school_outlined,
  ),
  language(
    'Language tests',
    'Your English and French test results',
    Icons.translate_rounded,
  ),
  work(
    'Work experience',
    'Skilled work in Canada and abroad, and trade certificates',
    Icons.work_outline_rounded,
  ),
  spouse(
    'Your spouse or partner',
    'Their education, language and Canadian work',
    Icons.people_outline_rounded,
  ),
  additional(
    'Additional factors',
    'A provincial nomination, or a sibling in Canada',
    Icons.star_outline_rounded,
  );

  const ProfileSection(this.title, this.summary, this.icon);

  final String title;
  final String summary;

  /// Outlined — these sit in list rows (`.agents/rules/01-stack.md`).
  final IconData icon;

  /// The spouse section only exists when IRCC would score a spouse.
  bool appliesTo(CrsProfile profile) =>
      this != ProfileSection.spouse || profile.scoresWithSpouse;

  bool isComplete(CrsProfile p, {required bool hasDateOfBirth}) {
    switch (this) {
      case ProfileSection.aboutYou:
        final status = p.maritalStatus;
        if (!hasDateOfBirth || status == null) return false;
        if (!status.hasPartner) return true;
        final accompanying = p.spouseAccompanying;
        return accompanying != null &&
            (!accompanying || p.spouseCanadianOrPr != null);
      case ProfileSection.education:
        return p.education != null && p.canadianEducation != null;
      case ProfileSection.language:
        return p.englishTest != null || p.frenchTest != null;
      case ProfileSection.work:
        return p.canadianWorkYears != null &&
            p.foreignWorkYears != null &&
            p.certificateOfQualification != null;
      case ProfileSection.spouse:
        // A spouse's language test is optional — many partners do not have
        // one — so it does not hold the section open.
        return p.spouseEducation != null && p.spouseCanadianWorkYears != null;
      case ProfileSection.additional:
        return p.provincialNomination != null && p.familyInCanada != null;
    }
  }
}

class ProfileCompletion {
  const ProfileCompletion({required this.sections, required this.done});

  /// The sections that apply to this candidate, in order.
  final List<ProfileSection> sections;
  final Set<ProfileSection> done;

  /// 0–100. Rendered by the one ring in the product.
  int get percent =>
      sections.isEmpty ? 100 : (done.length * 100 / sections.length).round();

  /// The first unfinished section — where the ring leads.
  ProfileSection? get next {
    for (final section in sections) {
      if (!done.contains(section)) return section;
    }
    return null;
  }
}

ProfileCompletion completionOf(
  CrsProfile profile, {
  required bool hasDateOfBirth,
}) {
  final sections = [
    for (final section in ProfileSection.values)
      if (section.appliesTo(profile)) section,
  ];
  return ProfileCompletion(
    sections: sections,
    done: {
      for (final section in sections)
        if (section.isComplete(profile, hasDateOfBirth: hasDateOfBirth))
          section,
    },
  );
}
