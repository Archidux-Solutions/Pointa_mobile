import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointa_mobile/features/auth/domain/exceptions/auth_exception.dart';
import 'package:pointa_mobile/features/auth/domain/models/user_session.dart';
import 'package:pointa_mobile/features/auth/domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return const MockAuthRepository();
});

class MockAuthRepository implements AuthRepository {
  const MockAuthRepository();

  @override
  Future<UserSession> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    if (email.trim().isEmpty || password.trim().isEmpty) {
      throw const AuthException('Email et mot de passe obligatoires.');
    }

    return UserSession(
      userId: 'mock-user-001',
      displayName: 'Membre Pointa',
      email: email.trim(),
    );
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
  }
}
