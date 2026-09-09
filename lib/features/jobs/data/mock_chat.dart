/// One message in a recruiter thread.
class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.fromMe,
    required this.time,
    this.action,
  });

  final String text;
  final bool fromMe;
  final String time;

  /// An inline action offered by the recruiter — "Join Interview".
  final String? action;
}

class ChatThread {
  const ChatThread({
    required this.id,
    required this.company,
    required this.contactName,
    required this.contactRole,
    required this.messages,
    required this.time,
    this.unread = 0,
    this.archived = false,
    this.online = false,
  });

  final String id;
  final String company;
  final String contactName;
  final String contactRole;
  final List<ChatMessage> messages;
  final String time;
  final int unread;
  final bool archived;
  final bool online;

  String get preview => messages.isEmpty ? '' : messages.last.text;
}

/// I1–I5 — five recruiter threads.
const List<ChatThread> mockChatThreads = [
  ChatThread(
    id: 'c1',
    company: 'Shopify',
    contactName: 'Renée Duval',
    contactRole: 'Talent Partner',
    time: '20:00',
    unread: 1,
    online: true,
    messages: [
      ChatMessage(
        text: 'Hi Adam, thanks for applying to Senior Product Designer. The '
            'team has reviewed your portfolio and would like to meet you.',
        fromMe: false,
        time: '19:41',
      ),
      ChatMessage(
        text: 'We have held Monday 17 March at 10:00 — 45 minutes, a portfolio '
            'walkthrough rather than a whiteboard exercise.',
        fromMe: false,
        time: '19:42',
        action: 'Join Interview',
      ),
      ChatMessage(
        text: 'That works, thank you. I will be there.',
        fromMe: true,
        time: '20:00',
      ),
    ],
  ),
  ChatThread(
    id: 'c2',
    company: 'Wealthsimple',
    contactName: 'Marcus Hall',
    contactRole: 'Design Hiring Manager',
    time: '19:17',
    messages: [
      ChatMessage(
        text: 'Congratulations Adam — the written offer is on its way to your '
            'email. It includes the work permit support we discussed.',
        fromMe: false,
        time: '19:17',
      ),
    ],
  ),
  ChatThread(
    id: 'c3',
    company: 'Hootsuite',
    contactName: 'Aisha Nkemdirim',
    contactRole: 'Recruiter',
    time: '18:48',
    messages: [
      ChatMessage(
        text: 'Your application is with the team. We usually close reviews '
            'within two weeks of posting.',
        fromMe: false,
        time: '18:48',
      ),
    ],
  ),
  ChatThread(
    id: 'c4',
    company: 'Clio',
    contactName: 'Tom Ferreira',
    contactRole: 'Talent Coordinator',
    time: '18:20',
    archived: true,
    messages: [
      ChatMessage(
        text: 'Thanks for your interest — we have paused this role until the '
            'next quarter. I will come back to you when it reopens.',
        fromMe: false,
        time: '18:20',
      ),
    ],
  ),
  ChatThread(
    id: 'c5',
    company: 'Benevity',
    contactName: 'Priya Raman',
    contactRole: 'People Team',
    time: '17:38',
    messages: [
      ChatMessage(
        text: 'Could you send a writing sample of 300 words or so? Anything '
            'you have written for a product is fine.',
        fromMe: false,
        time: '17:30',
      ),
      ChatMessage(
        text: 'Of course — I will send one over this evening.',
        fromMe: true,
        time: '17:38',
      ),
    ],
  ),
];
