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
      displayName: _displayNameFromEmail(email),
      email: email.trim(),
      phoneNumber: _phoneFromEmail(email),
    );
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
  }

  String _displayNameFromEmail(String email) {
    final localPart = email.split('@').first.trim();
    if (localPart.isEmpty) {
      return 'Membre Pointa';
    }

    final tokens = localPart
        .replaceAll(RegExp(r'[._-]+'), ' ')
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .take(3)
        .map(_capitalize)
        .toList();

    if (tokens.isEmpty) {
      return 'Membre Pointa';
    }

    return tokens.join(' ');
  }

  String _capitalize(String value) {
    final lowerCased = value.toLowerCase();
    return '${lowerCased[0].toUpperCase()}${lowerCased.substring(1)}';
  }

  String _phoneFromEmail(String email) {
    final digits = email
        .split('')
        .map((char) => char.codeUnitAt(0))
        .fold<int>(0, (sum, value) => sum + value)
        .toString()
        .padLeft(8, '0');

    return '+226 ${digits.substring(0, 2)} ${digits.substring(2, 4)} ${digits.substring(4, 6)} ${digits.substring(6, 8)}';
  }
}
