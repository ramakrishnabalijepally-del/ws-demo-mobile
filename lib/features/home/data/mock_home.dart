import '../models/tip.dart';

/// D2 — notifications.
///
/// The deck's version colours each row's avatar by the sending company. Here
/// the glyph carries the meaning and the row is neutral, so a notification
/// never reads as a status.
const List<AppNotification> mockNotifications = [
  AppNotification(
    id: 'n1',
    title: 'Shopify has read your application for Senior Product Designer',
    time: '2 hours ago',
    kind: NotificationKind.application,
    unread: true,
  ),
  AppNotification(
    id: 'n2',
    title: 'Interview scheduled with Wealthsimple for Monday 17 March, 10:00',
    time: '5 hours ago',
    kind: NotificationKind.application,
    unread: true,
  ),
  AppNotification(
    id: 'n3',
    title: 'Express Entry draw 302 closed at 468 — your predicted score is in '
        'range',
    time: 'Yesterday',
    kind: NotificationKind.immigration,
  ),
  AppNotification(
    id: 'n4',
    title: '12 new immigrant-friendly design roles in Toronto',
    time: 'Yesterday',
    kind: NotificationKind.job,
  ),
  AppNotification(
    id: 'n5',
    title: 'Priya Raman replied about your consultation booking',
    time: '2 days ago',
    kind: NotificationKind.message,
  ),
  AppNotification(
    id: 'n6',
    title: 'Your Smart Checklist has 3 steps due this month',
    time: '3 days ago',
    kind: NotificationKind.system,
  ),
];

/// D3–D4 — tips, with real body copy so the article screen is not a lorem
/// placeholder.
const List<Tip> mockTips = [
  Tip(
    id: 't1',
    title: 'How to write a Canadian-style resume',
    authorName: 'Sarah Bolinas',
    authorRole: 'Head of Talent, Toronto',
    readMinutes: 4,
    body: [
      'A Canadian resume is shorter and plainer than the CV most newcomers '
          'arrive with. Two pages is the ceiling, one is common, and anything '
          'longer is usually skimmed rather than read.',
      'Leave out your photo, your date of birth, your marital status and your '
          'nationality. Canadian employers are not permitted to consider them, '
          'and including them can slow an application down rather than help it.',
      'Lead each role with what changed because you were there. "Redesigned '
          'the onboarding flow, cutting drop-off from 41% to 26%" says more '
          'than three lines describing the same job in the abstract.',
      'Name your work permit status near the top. Employers who are open to '
          'hiring newcomers want to know quickly, and the ones who are not will '
          'screen you out either way — better that it happens in week one than '
          'week five.',
    ],
  ),
  Tip(
    id: 't2',
    title: 'What actually moves your CRS score',
    authorName: 'Daniel Okonkwo',
    authorRole: 'Regulated Canadian Immigration Consultant',
    readMinutes: 6,
    body: [
      'Most people can move their Comprehensive Ranking System score by more '
          'than they expect, but not through the factors they tend to focus on.',
      'Language is the biggest lever. Going from CLB 7 to CLB 9 across all four '
          'abilities is worth up to 50 points on its own, and more again through '
          'the skill transferability combinations. A second test sitting costs '
          'less than almost any other route to the same points.',
      'A provincial nomination is worth 600 points and effectively guarantees '
          'an invitation. If your occupation is in demand in a specific '
          'province, that is usually the shortest path.',
      'French matters more than most applicants realise: strong French adds up '
          'to 50 points even if English is your stronger language, and several '
          'draws have been French-only.',
      'Age points decline from 30 onward. That is not a reason to panic, but it '
          'is a reason not to leave a profile sitting incomplete for a year.',
    ],
  ),
  Tip(
    id: 't3',
    title: 'Getting your credentials recognised',
    authorName: 'Mei Lin Chow',
    authorRole: 'Settlement Advisor',
    readMinutes: 5,
    body: [
      'An Educational Credential Assessment tells Immigration, Refugees and '
          'Citizenship Canada what your foreign degree is worth in Canadian '
          'terms. It is required for Express Entry and it takes weeks, so start '
          'it before you think you need it.',
      'An ECA is not the same thing as a professional licence. If you work in a '
          'regulated occupation — nursing, engineering, teaching, accounting — '
          'the provincial regulator decides whether you can practise, and its '
          'process runs separately from the immigration one.',
      'Ask the regulator what they accept before you pay for anything. Some '
          'recognise specific overseas bodies directly, which can remove a step '
          'entirely.',
    ],
  ),
];
