class PasswordResetChallenge {
  const PasswordResetChallenge({
    required this.requestId,
    this.verificationCode,
    this.expiresInSeconds = 600,
    this.message =
        'Si un compte existe, un code de reinitialisation a ete emis.',
  });

  final String requestId;
  final String? verificationCode;
  final int expiresInSeconds;
  final String message;
}
