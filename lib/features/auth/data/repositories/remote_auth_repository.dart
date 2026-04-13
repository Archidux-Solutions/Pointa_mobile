import 'dart:convert';

import 'package:pointa_mobile/core/network/api_exception.dart';
import 'package:pointa_mobile/core/network/api_session_store.dart';
import 'package:pointa_mobile/core/network/pointa_api_client.dart';
import 'package:pointa_mobile/features/auth/data/session/mobile_installation_service.dart';
import 'package:pointa_mobile/features/auth/domain/exceptions/auth_exception.dart';
import 'package:pointa_mobile/features/auth/domain/models/password_reset_challenge.dart';
import 'package:pointa_mobile/features/auth/domain/models/user_session.dart';
import 'package:pointa_mobile/features/auth/domain/repositories/auth_repository.dart';

class RemoteAuthRepository implements AuthRepository {
  RemoteAuthRepository({
    required PointaApiClient apiClient,
    required ApiSessionStore sessionStore,
    required MobileInstallationService mobileInstallationService,
  }) : _apiClient = apiClient,
       _sessionStore = sessionStore,
       _mobileInstallationService = mobileInstallationService;

  final PointaApiClient _apiClient;
  final ApiSessionStore _sessionStore;
  final MobileInstallationService _mobileInstallationService;

  @override
  Future<UserSession> signIn({
    required String phone,
    required String password,
  }) async {
    try {
      final deviceIdentity = await _mobileInstallationService.getIdentity();
      final payload = await _apiClient.sendJson(
        method: 'POST',
        path: '/api/auth/login/',
        body: <String, dynamic>{
          'phone': phone.trim(),
          'password': password,
          'device_installation_id': deviceIdentity.installationId,
          'device_platform': deviceIdentity.platform,
        },
      );

      final accessToken = _readRequiredString(payload, 'access');
      final refreshToken = _readRequiredString(payload, 'refresh');
      final userId = _extractUserId(accessToken);

      _sessionStore.update(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      return _fetchSession(fallbackPhone: phone.trim(), userId: userId);
    } on ApiException catch (error) {
      _sessionStore.clear();
      throw AuthException(error.message);
    }
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (_sessionStore.accessToken == null) {
      throw const AuthException('Session expiree. Reconnectez-vous.');
    }

    try {
      await _apiClient.sendJson(
        method: 'POST',
        path: '/api/auth/change-password/',
        body: <String, dynamic>{
          'old_password': oldPassword,
          'new_password': newPassword,
        },
        authenticated: true,
      );
    } on ApiException catch (error) {
      throw AuthException(error.message);
    }
  }

  @override
  Future<UserSession> updateProfile({
    required String fullName,
    required String email,
    required String phone,
  }) async {
    if (_sessionStore.accessToken == null) {
      throw const AuthException('Session expiree. Reconnectez-vous.');
    }

    try {
      final name = _splitName(fullName);
      final payload = await _apiClient.sendJson(
        method: 'PATCH',
        path: '/api/auth/me/',
        body: <String, dynamic>{
          'first_name': name.firstName,
          'last_name': name.lastName,
          'email': email.trim(),
          'phone': phone.trim(),
        },
        authenticated: true,
      );

      if (payload is! Map<String, dynamic>) {
        throw const AuthException('Profil utilisateur introuvable.');
      }

      final accessToken = _sessionStore.accessToken;
      if (accessToken == null || accessToken.isEmpty) {
        throw const AuthException('Session expiree. Reconnectez-vous.');
      }

      final userId = _extractUserId(accessToken);
      final responseUserId = '${payload['id'] ?? ''}'.trim();
      if (responseUserId.isNotEmpty && responseUserId != userId) {
        throw const AuthException('Profil utilisateur incoherent.');
      }

      final firstName = (payload['first_name'] as String?)?.trim() ?? '';
      final lastName = (payload['last_name'] as String?)?.trim() ?? '';
      final displayName = '$firstName $lastName'.trim();

      return UserSession(
        userId: userId,
        displayName: displayName.isEmpty ? fullName.trim() : displayName,
        email: (payload['email'] as String?)?.trim() ?? email.trim(),
        phoneNumber: (payload['phone'] as String?)?.trim() ?? phone.trim(),
      );
    } on ApiException catch (error) {
      throw AuthException(error.message);
    }
  }

  @override
  Future<PasswordResetChallenge> requestPasswordReset({
    required String phone,
    String channel = 'auto',
  }) async {
    try {
      final payload = await _apiClient.sendJson(
        method: 'POST',
        path: '/api/auth/forgot-password/',
        body: <String, dynamic>{
          'phone': phone.trim(),
          'channel': channel.trim(),
        },
      );

      return PasswordResetChallenge(
        requestId: _readRequiredString(payload, 'request_id'),
        verificationCode: _readOptionalString(payload, 'verification_code'),
        expiresInSeconds:
            _readOptionalInt(payload, 'expires_in_seconds') ?? 600,
        message:
            _readOptionalString(payload, 'message') ??
            'Si un compte existe, un code de reinitialisation a ete emis.',
      );
    } on ApiException catch (error) {
      throw AuthException(error.message);
    }
  }

  @override
  Future<void> resetPassword({
    required String requestId,
    required String verificationCode,
    required String newPassword,
  }) async {
    try {
      await _apiClient.sendJson(
        method: 'POST',
        path: '/api/auth/reset-password/',
        body: <String, dynamic>{
          'request_id': requestId.trim(),
          'verification_code': verificationCode.trim(),
          'new_password': newPassword,
        },
      );
    } on ApiException catch (error) {
      throw AuthException(error.message);
    }
  }

  @override
  Future<void> deleteAccount({required String currentPassword}) async {
    if (_sessionStore.accessToken == null) {
      throw const AuthException('Session expiree. Reconnectez-vous.');
    }

    try {
      await _apiClient.sendJson(
        method: 'POST',
        path: '/api/auth/delete-account/',
        body: <String, dynamic>{
          'current_password': currentPassword,
          'refresh': _sessionStore.refreshToken,
        },
        authenticated: true,
      );
    } on ApiException catch (error) {
      throw AuthException(error.message);
    } finally {
      _sessionStore.clear();
    }
  }

  @override
  Future<void> signOut() async {
    final hasSession =
        (_sessionStore.accessToken?.isNotEmpty ?? false) &&
        (_sessionStore.refreshToken?.isNotEmpty ?? false);

    if (!hasSession) {
      _sessionStore.clear();
      return;
    }

    try {
      await _apiClient.sendJson(
        method: 'POST',
        path: '/api/auth/logout/',
        body: <String, dynamic>{'refresh': _sessionStore.refreshToken},
        authenticated: true,
      );
    } on ApiException {
      // Keep local sign-out resilient even if the remote session revocation fails.
    } finally {
      _sessionStore.clear();
    }
  }

  Future<UserSession> _fetchSession({
    required String fallbackPhone,
    required String userId,
  }) async {
    try {
      final payload = await _apiClient.sendJson(
        method: 'GET',
        path: '/api/auth/me/',
        authenticated: true,
      );

      if (payload is! Map<String, dynamic>) {
        throw const AuthException('Profil utilisateur introuvable.');
      }

      final responseUserId = '${payload['id'] ?? ''}'.trim();
      if (responseUserId.isNotEmpty && responseUserId != userId) {
        throw const AuthException('Profil utilisateur incoherent.');
      }

      final firstName = (payload['first_name'] as String?)?.trim() ?? '';
      final lastName = (payload['last_name'] as String?)?.trim() ?? '';
      final displayName = '$firstName $lastName'.trim();

      return UserSession(
        userId: userId,
        displayName: displayName.isEmpty ? 'Membre Pointa' : displayName,
        email: (payload['email'] as String?)?.trim() ?? '',
        phoneNumber: (payload['phone'] as String?)?.trim().isNotEmpty == true
            ? (payload['phone'] as String).trim()
            : fallbackPhone,
      );
    } on ApiException catch (error) {
      throw AuthException(error.message);
    }
  }

  String _readRequiredString(dynamic payload, String key) {
    if (payload is Map<String, dynamic>) {
      final value = payload[key]?.toString().trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    throw const AuthException('Reponse backend incomplete.');
  }

  String? _readOptionalString(dynamic payload, String key) {
    if (payload is Map<String, dynamic>) {
      final value = payload[key]?.toString().trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  int? _readOptionalInt(dynamic payload, String key) {
    if (payload is Map<String, dynamic>) {
      final rawValue = payload[key];
      if (rawValue is int) {
        return rawValue;
      }
      final parsedValue = int.tryParse('${rawValue ?? ''}'.trim());
      if (parsedValue != null) {
        return parsedValue;
      }
    }
    return null;
  }

  String _extractUserId(String accessToken) {
    try {
      final parts = accessToken.split('.');
      if (parts.length != 3) {
        throw const AuthException('Token backend invalide.');
      }

      final payload = parts[1];
      final normalizedPayload = base64Url.normalize(payload);
      final decodedPayload = utf8.decode(base64Url.decode(normalizedPayload));
      final jwtMap = jsonDecode(decodedPayload);

      if (jwtMap is Map<String, dynamic>) {
        final userId = jwtMap['user_id']?.toString().trim();
        if (userId != null && userId.isNotEmpty) {
          return userId;
        }
      }
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException('Token backend invalide.');
    }

    throw const AuthException('Identifiant utilisateur absent du token.');
  }

  _NameParts _splitName(String fullName) {
    final normalized = fullName.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.isEmpty) {
      return const _NameParts(firstName: 'Pointa', lastName: 'Utilisateur');
    }

    final segments = normalized.split(' ');
    if (segments.length == 1) {
      return _NameParts(firstName: segments.first, lastName: 'Pointa');
    }

    return _NameParts(
      firstName: segments.first,
      lastName: segments.sublist(1).join(' '),
    );
  }
}

class _NameParts {
  const _NameParts({required this.firstName, required this.lastName});

  final String firstName;
  final String lastName;
}
