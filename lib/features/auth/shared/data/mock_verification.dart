/// Stand-ins for the emailed one-time code until Supabase Auth is wired up.
///
/// TODO(backend): delete this file once real OTP emails are sent — the code
/// is then issued and checked server-side, never known to the app.
library;

/// The code every mock email "sends", for registration and password reset
/// alike. Shown in a dev-only banner on the verify screen so nobody has to
/// guess it.
const String mockVerificationCode = '482913';

/// Digits in a verification code.
const int verificationCodeLength = 6;

/// A ready-made candidate for walking the sign-up and forgot-password flows
/// end to end — prefilled as the field hint so testers can copy it.
class MockCandidate {
  const MockCandidate({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String phone;
}

const MockCandidate mockCandidate = MockCandidate(
  firstName: 'Amina',
  lastName: 'Hassan',
  email: 'amina.hassan@example.com',
  phone: '4165550142',
);
