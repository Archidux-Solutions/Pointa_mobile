class UserSession {
  const UserSession({
    required this.userId,
    required this.displayName,
    required this.email,
  });

  final String userId;
  final String displayName;
  final String email;
}
