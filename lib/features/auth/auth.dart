/// Authentication — sign in, sign up, password reset, and the account-created
/// milestone.
///
/// **No authentication actually happens.** Every screen here is layout and
/// validation copy; signing in flips an in-memory flag
/// (`.agents/rules/02-structure.md`, mock-UI protocol).
library;

export 'forgot_password/presentation/screens/forgot_password_screen.dart';
export 'forgot_password/presentation/screens/reset_method_screen.dart';
export 'shared/presentation/screens/account_created_screen.dart';
export 'sign_in/presentation/screens/sign_in_screen.dart';
export 'sign_up/presentation/screens/sign_up_screen.dart';
