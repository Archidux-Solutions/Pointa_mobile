import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointa_mobile/features/auth/domain/models/user_session.dart';

final persistedAuthSessionStoreProvider = Provider<PersistedAuthSessionStore>((
  ref,
) {
  return PersistedAuthSessionStore(const FlutterSecureStorage());
});

class PersistedAuthSessionStore {
  PersistedAuthSessionStore(this._storage);

  static const _storageKey = 'pointa.auth.session';

  final FlutterSecureStorage _storage;

  Future<void> save({
    required UserSession session,
    required String accessToken,
    required String refreshToken,
  }) {
    return _storage.write(
      key: _storageKey,
      value: jsonEncode(<String, dynamic>{
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'user_id': session.userId,
        'display_name': session.displayName,
        'email': session.email,
        'phone_number': session.phoneNumber,
      }),
    );
  }

  Future<PersistedAuthSession?> read() async {
    final rawValue = await _storage.read(key: _storageKey);
    if (rawValue == null || rawValue.trim().isEmpty) {
      return null;
    }

    final decoded = jsonDecode(rawValue);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    final accessToken = decoded['access_token']?.toString().trim();
    final refreshToken = decoded['refresh_token']?.toString().trim();
    final userId = decoded['user_id']?.toString().trim();
    final displayName = decoded['display_name']?.toString().trim();
    final email = decoded['email']?.toString().trim();

    if (accessToken == null ||
        accessToken.isEmpty ||
        refreshToken == null ||
        refreshToken.isEmpty ||
        userId == null ||
        userId.isEmpty ||
        displayName == null ||
        displayName.isEmpty ||
        email == null) {
      return null;
    }

    return PersistedAuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      session: UserSession(
        userId: userId,
        displayName: displayName,
        email: email,
        phoneNumber: decoded['phone_number']?.toString().trim(),
      ),
    );
  }

  Future<void> clear() => _storage.delete(key: _storageKey);
}

class PersistedAuthSession {
  const PersistedAuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.session,
  });

  final String accessToken;
  final String refreshToken;
  final UserSession session;
}
