import 'package:pointa_mobile/features/auth/domain/models/user_session.dart';

abstract class AuthRepository {
  Future<UserSession> signIn({required String phone, required String password});

  Future<UserSession> register({
    required String fullName,
    required String phone,
    required String email,
    required String password,
  });

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  Future<String> requestPasswordReset({required String phone});

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  });

  Future<void> signOut();
}
