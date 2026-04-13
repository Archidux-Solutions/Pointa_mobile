import 'package:pointa_mobile/features/auth/domain/models/password_reset_challenge.dart';
import 'package:pointa_mobile/features/auth/domain/models/user_session.dart';

abstract class AuthRepository {
  Future<UserSession> signIn({required String phone, required String password});

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  Future<UserSession> updateProfile({
    required String fullName,
    required String email,
    required String phone,
  });

  Future<PasswordResetChallenge> requestPasswordReset({
    required String phone,
    String channel = 'auto',
  });

  Future<void> resetPassword({
    required String requestId,
    required String verificationCode,
    required String newPassword,
  });

  Future<void> deleteAccount({required String currentPassword});

  Future<void> signOut();
}
