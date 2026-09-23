/// The fixed option sets the registration flow offers.
///
/// Names the province, the program and the stream in full on first use, per
/// design system section 20.
library;

/// Profile Type — four options, as selection cards. Labels match
/// `candidateProfileTypes`, which the profile form offers.
const List<({String label, String blurb})> mockProfileTypes = [
  (
    label: 'Job Seeker',
    blurb: 'Looking for work in Canada now or soon',
  ),
  (
    label: 'Student',
    blurb: 'Studying in Canada, or planning to',
  ),
  (
    label: 'Permanent Residence Applicant',
    blurb: 'Applying to settle in Canada permanently',
  ),
  (
    label: 'Other',
    blurb: 'Already settled, or here for another reason',
  ),
];
