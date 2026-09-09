/// Registration — design system Pattern A.
///
/// One decision per screen, a segment bar throughout, and a review before
/// anything is committed. The steps themselves are widgets, private to the
/// feature; only the flow screen is public.
library;

export 'controllers/registration_controller.dart' show registrationProvider;
export 'presentation/screens/registration_screen.dart' show RegistrationScreen;
