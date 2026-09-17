/// The AI agent — the product's one AI surface, and the middle tab.
///
/// **Agentic, not a chat box.** The hub opens with what the agent has already
/// noticed in the candidate's profile; the conversation, voice mode and saved
/// answers sit behind it. Appointments live here too, because the agent is
/// what works out that a question needs a licensed human.
///
/// Voice mode inverts the screen to Grey 950 in **both** themes, which is why
/// it is pushed above the shell rather than inside the tab.
library;

export 'agent/presentation/screens/ai_agent_screen.dart';
export 'appointments/presentation/screens/appointment_screens.dart';
export 'chat/presentation/screens/assistant_screen.dart';
export 'data/mock_appointments.dart' show Consultation, mockConsultations;
export 'voice/presentation/screens/voice_mode_screen.dart';
