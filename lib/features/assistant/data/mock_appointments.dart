/// A bookable consultation.
///
/// Appointments live with the AI agent rather than with Settlement: the agent
/// is what notices you need one, so booking a human is the escalation at the
/// end of its own flow.
class Consultation {
  const Consultation({
    required this.id,
    required this.title,
    required this.minutes,
    required this.price,
    required this.summary,
    required this.consultant,
    required this.credential,
  });

  final String id;
  final String title;
  final int minutes;

  /// Canadian dollars. Zero means free.
  final int price;

  final String summary;
  final String consultant;
  final String credential;
}

/// The consultations on offer, every one with a licensed RCIC behind it.
const List<Consultation> mockConsultations = [
  Consultation(
    id: 'c1',
    title: 'Profile assessment and pathway consultation',
    minutes: 60,
    price: 180,
    summary: 'A full review of your profile against every program you could '
        'reach, and a written pathway afterwards.',
    consultant: 'Daniel Okonkwo',
    credential: 'RCIC · R512844',
  ),
  Consultation(
    id: 'c2',
    title: 'General immigration consultation',
    minutes: 30,
    price: 95,
    summary: 'Bring your questions. Good for a second opinion on a decision '
        'you have already half made.',
    consultant: 'Priya Raman',
    credential: 'RCIC · R709122',
  ),
  Consultation(
    id: 'c3',
    title: 'Phone consultation',
    minutes: 15,
    price: 45,
    summary: 'One question, answered properly.',
    consultant: 'Priya Raman',
    credential: 'RCIC · R709122',
  ),
  Consultation(
    id: 'c4',
    title: 'Alberta PNP program guidance',
    minutes: 45,
    price: 140,
    summary: 'Which Alberta stream fits, and what would need to change for the '
        'others.',
    consultant: 'Mei Lin Chow',
    credential: 'RCIC · R641003',
  ),
  Consultation(
    id: 'c5',
    title: 'British Columbia PNP program guidance',
    minutes: 45,
    price: 140,
    summary: 'BC Tech and Skills Immigration, and what the job offer has to '
        'look like.',
    consultant: 'Mei Lin Chow',
    credential: 'RCIC · R641003',
  ),
  Consultation(
    id: 'c6',
    title: 'Rural and Northern Immigration Pilot consultation',
    minutes: 45,
    price: 140,
    summary: 'The participating communities, and how a recommendation works.',
    consultant: 'Daniel Okonkwo',
    credential: 'RCIC · R512844',
  ),
];
