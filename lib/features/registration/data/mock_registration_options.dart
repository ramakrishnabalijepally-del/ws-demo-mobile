/// The fixed option sets the registration flow offers.
///
/// Names the province, the program and the stream in full on first use, per
/// design system section 20.
library;

/// Profile Type — the deck's three options, as selection cards.
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
    label: 'Other',
    blurb: 'Settling for family, business or another reason',
  ),
];

/// Your Goals — multi-select. Written in the second person, as the voice rules
/// ask.
const List<String> mockGoals = [
  'Find a job in my field',
  'Apply for permanent residence',
  'Understand which programs I qualify for',
  'Predict my CRS score',
  'Improve my French',
  'Book a consultation with a licensed RCIC',
  'Get my credentials recognised',
  'Settle my family in Canada',
];

/// C6 — "What job do you want?", pick three to five.
const List<String> mockJobCategories = [
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

/// The provinces and territories, for the contact step and the PNP list.
const List<String> mockProvinces = [
  'Alberta',
  'British Columbia',
  'Manitoba',
  'New Brunswick',
  'Newfoundland and Labrador',
  'Nova Scotia',
  'Ontario',
  'Prince Edward Island',
  'Quebec',
  'Saskatchewan',
  'Northwest Territories',
  'Nunavut',
  'Yukon',
];
