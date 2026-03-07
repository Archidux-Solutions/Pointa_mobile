class UserSession {
  const UserSession({
    required this.userId,
    required this.displayName,
    required this.email,
    this.phoneNumber,
  });

  final String userId;
  final String displayName;
  final String email;
  final String? phoneNumber;
}
