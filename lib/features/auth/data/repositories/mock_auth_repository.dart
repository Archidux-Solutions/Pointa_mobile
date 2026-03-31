import 'dart:async';

import 'package:pointa_mobile/features/auth/domain/exceptions/auth_exception.dart';
import 'package:pointa_mobile/features/auth/domain/models/user_session.dart';
import 'package:pointa_mobile/features/auth/domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  const MockAuthRepository();

  @override
  Future<UserSession> signIn({
    required String phone,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    if (phone.trim().isEmpty || password.trim().isEmpty) {
      throw const AuthException('Telephone et mot de passe obligatoires.');
    }

    return UserSession(
      userId: 'mock-user-001',
      displayName: 'Membre Pointa',
      email: '${phone.trim()}@pointa.app',
      phoneNumber: phone.trim(),
    );
  }

  @override
  Future<UserSession> register({
    required String fullName,
    required String phone,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    if (fullName.trim().isEmpty ||
        phone.trim().isEmpty ||
        email.trim().isEmpty ||
        password.trim().isEmpty) {
      throw const AuthException('Tous les champs sont obligatoires.');
    }

    return UserSession(
      userId: 'mock-user-001',
      displayName: fullName.trim(),
      email: email.trim(),
      phoneNumber: phone.trim(),
    );
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));

    if (oldPassword.trim().isEmpty || newPassword.trim().isEmpty) {
      throw const AuthException('Renseignez les deux mots de passe.');
    }
  }

  @override
  Future<UserSession> updateProfile({
    required String fullName,
    required String email,
    required String phone,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));

    if (fullName.trim().isEmpty ||
        email.trim().isEmpty ||
        phone.trim().isEmpty) {
      throw const AuthException('Tous les champs du profil sont obligatoires.');
    }

    return UserSession(
      userId: 'mock-user-001',
      displayName: fullName.trim(),
      email: email.trim(),
      phoneNumber: phone.trim(),
    );
  }

  @override
  Future<String> requestPasswordReset({required String phone}) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));

    if (phone.trim().isEmpty) {
      throw const AuthException('Renseignez votre numero de telephone.');
    }

    return 'mock-reset-token';
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));

    if (token.trim().isEmpty || newPassword.trim().isEmpty) {
      throw const AuthException('Impossible de reinitialiser le mot de passe.');
    }
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
  }
}
