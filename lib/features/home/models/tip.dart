/// An article in "Tips for you".
class Tip {
  const Tip({
    required this.id,
    required this.title,
    required this.authorName,
    required this.authorRole,
    required this.readMinutes,
    required this.body,
  });

  final String id;
  final String title;
  final String authorName;
  final String authorRole;
  final int readMinutes;

  /// Paragraphs.
  final List<String> body;
}

/// A notification row.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.time,
    required this.kind,
    this.unread = false,
  });

  final String id;
  final String title;
  final String time;
  final NotificationKind kind;
  final bool unread;
}

/// What the notification is about. **Not a colour** — the glyph does the work,
/// as everywhere else in this system.
enum NotificationKind { application, job, immigration, message, system }
