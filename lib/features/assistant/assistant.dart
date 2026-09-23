/// The AI agent — the product's one AI surface, and the middle tab.
///
/// The tab opens straight into the conversation, with the globe and the
/// frequently asked questions as its empty state. Voice mode and saved answers
/// sit behind the chat's app bar; appointments stay reachable by route.
///
/// Voice mode inverts the screen to Grey 950 in **both** themes, which is why
/// it is pushed above the shell rather than inside the tab.
library;

export 'appointments/presentation/screens/appointment_screens.dart';
export 'chat/presentation/screens/assistant_screen.dart';
export 'data/mock_appointments.dart' show Consultation, mockConsultations;
export 'voice/presentation/screens/voice_mode_screen.dart';
