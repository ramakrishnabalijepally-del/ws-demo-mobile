import '../../../app/providers.dart';

class Plan {
  const Plan({
    required this.tier,
    required this.name,
    required this.monthly,
    required this.blurb,
    required this.features,
    this.mostPopular = false,
  });

  final PlanTier tier;
  final String name;

  /// Canadian dollars per month. Zero is free.
  final int monthly;

  final String blurb;
  final List<String> features;
  final bool mostPopular;

  /// Yearly saves 17%, which is two months.
  int get yearly => (monthly * 12 * 0.83).round();
}

const List<Plan> mockPlans = [
  Plan(
    tier: PlanTier.free,
    name: 'Free',
    monthly: 0,
    blurb: 'Basic profile and job search are always free.',
    features: [
      'Your full profile',
      'Search and apply to every job',
      'Save jobs and track applications',
      'Message employers who reply',
    ],
  ),
  Plan(
    tier: PlanTier.pro,
    name: 'Pro',
    monthly: 10,
    mostPopular: true,
    blurb: 'The AI tools, for people actually applying.',
    features: [
      'Everything in Free',
      'CRS Predictor and score breakdown',
      'Provincial and federal eligibility',
      'AI chat and voice assistant',
      'Smart Checklist',
      'Book consultations',
    ],
  ),
  Plan(
    tier: PlanTier.proPlus,
    name: 'Pro+',
    monthly: 50,
    blurb: 'For people who want a person as well as a product.',
    features: [
      'Everything in Pro',
      'French language support',
      'Priority appointment slots',
      'Expert Q&A',
      'Monthly webinars',
    ],
  ),
];

/// O3 — the comparison matrix.
///
/// Included is a red tick, free is the word "Free", **and a feature a tier does
/// not include is an em dash — never a cross and never a red X. Absence is
/// neutral information; the product does not punish the cheaper choice
/// visually** (design system section 16).
const List<({String feature, bool free, bool pro, bool proPlus})>
    mockComparison = [
  (feature: 'Profile and job search', free: true, pro: true, proPlus: true),
  (
    feature: 'Apply and track applications',
    free: true,
    pro: true,
    proPlus: true
  ),
  (feature: 'Employer messaging', free: true, pro: true, proPlus: true),
  (feature: 'CRS Predictor', free: false, pro: true, proPlus: true),
  (feature: 'Score breakdown', free: false, pro: true, proPlus: true),
  (feature: 'Provincial eligibility', free: false, pro: true, proPlus: true),
  (feature: 'Federal program matching', free: false, pro: true, proPlus: true),
  (feature: 'AI chat assistant', free: false, pro: true, proPlus: true),
  (feature: 'AI voice assistant', free: false, pro: true, proPlus: true),
  (feature: 'Smart Checklist', free: false, pro: true, proPlus: true),
  (feature: 'Book consultations', free: false, pro: true, proPlus: true),
  (feature: 'French language support', free: false, pro: false, proPlus: true),
  (feature: 'Priority appointments', free: false, pro: false, proPlus: true),
  (feature: 'Expert Q&A and webinars', free: false, pro: false, proPlus: true),
];

const List<({String label, String detail})> mockPaymentMethods = [
  (label: 'Card', detail: 'Visa, Mastercard or American Express'),
  (label: 'PayPal', detail: 'Pay with your PayPal balance or a linked card'),
  (label: 'Apple Pay', detail: 'Confirm with Face ID'),
  (label: 'Google Pay', detail: 'Confirm on your device'),
];
