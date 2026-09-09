import '../models/job.dart';
import 'mock_jobs.dart';

/// G1–G5 — five applications covering every status.
///
/// The letters are written the way the design system asks: they name the next
/// move, and the "not selected" one does not leave the reader without one.
final List<JobApplication> mockApplications = [
  JobApplication(
    id: 'a1',
    job: mockJobs[0],
    status: ApplicationStatus.interview,
    appliedOn: '3 March 2026',
    interviewOn: 'Monday 17 March, 10:00',
    message: 'Hi Adam,\n\n'
        'Thanks for applying. The team reviewed your portfolio and would like '
        'to meet you. We have held Monday 17 March at 10:00 for a 45-minute '
        'conversation with the design lead and one engineer.\n\n'
        'It is a portfolio walkthrough rather than a whiteboard exercise — '
        'bring two projects you can talk about in depth.\n\n'
        'Best regards,\nHiring Team, Shopify',
  ),
  JobApplication(
    id: 'a2',
    job: mockJobs[1],
    status: ApplicationStatus.offer,
    appliedOn: '18 February 2026',
    message: 'Hi Adam,\n\n'
        'We would like to offer you the UX Designer role. The written offer is '
        'on its way to your email, and it includes the details on work permit '
        'support we discussed.\n\n'
        'Take the time you need to read it. If anything is unclear, reply here '
        'and we will walk through it.\n\n'
        'Congratulations.\nHiring Team, Wealthsimple',
  ),
  JobApplication(
    id: 'a3',
    job: mockJobs[2],
    status: ApplicationStatus.underReview,
    appliedOn: '6 March 2026',
    message: 'Your application is with the hiring team. Most reviews at '
        'Hootsuite close within two weeks of the posting date.',
  ),
  JobApplication(
    id: 'a4',
    job: mockJobs[4],
    status: ApplicationStatus.submitted,
    appliedOn: '8 March 2026',
    message: 'Your application has been received. Nothing is needed from you '
        'right now.',
  ),
  JobApplication(
    id: 'a5',
    job: mockJobs[7],
    status: ApplicationStatus.notSelected,
    appliedOn: '20 January 2026',
    message: 'Hi Adam,\n\n'
        'We have decided to move forward with other candidates for the '
        'Marketing Manager role. The team was looking for more lifecycle '
        'experience in a direct-to-consumer setting specifically.\n\n'
        'Your portfolio was strong and we would welcome an application for '
        'future openings — we post new roles monthly.\n\n'
        'Best regards,\nHiring Team, Article',
  ),
];
