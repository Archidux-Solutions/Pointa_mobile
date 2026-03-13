import 'dart:convert';
import 'dart:io';

import 'package:pointa_mobile/features/auth/domain/exceptions/auth_exception.dart';
import 'package:pointa_mobile/features/auth/domain/models/user_session.dart';
import 'package:pointa_mobile/features/auth/domain/repositories/auth_repository.dart';

class RemoteAuthRepository implements AuthRepository {
  RemoteAuthRepository({
    required String baseUrl,
    HttpClient Function()? httpClientFactory,
  }) : _baseUrl = baseUrl.trim().replaceFirst(RegExp(r'/$'), ''),
       _httpClientFactory = httpClientFactory ?? HttpClient.new;

  final String _baseUrl;
  final HttpClient Function() _httpClientFactory;

  String? _accessToken;
  String? _refreshToken;

  @override
  Future<UserSession> signIn({
    required String phone,
    required String password,
  }) async {
    final payload = await _sendJson(
      method: 'POST',
      path: '/api/auth/login/',
      body: <String, dynamic>{'phone': phone.trim(), 'password': password},
    );

    final accessToken = _readRequiredString(payload, 'access');
    final refreshToken = _readRequiredString(payload, 'refresh');
    final userId = _extractUserId(accessToken);
    final session = await _fetchSession(
      accessToken: accessToken,
      fallbackPhone: phone.trim(),
      userId: userId,
    );

    _accessToken = accessToken;
    _refreshToken = refreshToken;
    return session;
  }

  @override
  Future<UserSession> register({
    required String fullName,
    required String phone,
    required String email,
    required String password,
  }) async {
    final name = _splitName(fullName);
    await _sendJson(
      method: 'POST',
      path: '/api/auth/register/',
      body: <String, dynamic>{
        'phone': phone.trim(),
        'email': email.trim(),
        'first_name': name.firstName,
        'last_name': name.lastName,
        'password': password,
      },
    );

    return signIn(phone: phone, password: password);
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final accessToken = _accessToken;
    if (accessToken == null) {
      throw const AuthException('Session expiree. Reconnectez-vous.');
    }

    await _sendJson(
      method: 'POST',
      path: '/api/auth/change-password/',
      body: <String, dynamic>{
        'old_password': oldPassword,
        'new_password': newPassword,
      },
      accessToken: accessToken,
    );
  }

  @override
  Future<String> requestPasswordReset({required String phone}) async {
    final payload = await _sendJson(
      method: 'POST',
      path: '/api/auth/forgot-password/',
      body: <String, dynamic>{'phone': phone.trim()},
    );

    return _readRequiredString(payload, 'reset_token');
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await _sendJson(
      method: 'POST',
      path: '/api/auth/reset-password/',
      body: <String, dynamic>{
        'token': token.trim(),
        'new_password': newPassword,
      },
    );
  }

  @override
  Future<void> signOut() async {
    final accessToken = _accessToken;
    final refreshToken = _refreshToken;

    _accessToken = null;
    _refreshToken = null;

    if (accessToken == null || refreshToken == null) {
      return;
    }

    try {
      await _sendJson(
        method: 'POST',
        path: '/api/auth/logout/',
        body: <String, dynamic>{'refresh': refreshToken},
        accessToken: accessToken,
      );
    } catch (_) {
      // The backend logout currently returns 400 if token blacklisting is not configured.
    }
  }

  Future<UserSession> _fetchSession({
    required String accessToken,
    required String fallbackPhone,
    required String userId,
  }) async {
    final payload = await _sendJson(
      method: 'GET',
      path: '/api/auth/users/',
      accessToken: accessToken,
    );

    if (payload is! List) {
      throw const AuthException('Profil utilisateur introuvable.');
    }

    final userMap = payload
        .cast<dynamic>()
        .whereType<Map<String, dynamic>>()
        .firstWhere(
          (user) => '${user['id'] ?? ''}' == userId,
          orElse: () => <String, dynamic>{},
        );

    final firstName = (userMap['first_name'] as String?)?.trim() ?? '';
    final lastName = (userMap['last_name'] as String?)?.trim() ?? '';
    final displayName = '$firstName $lastName'.trim();

    return UserSession(
      userId: userId,
      displayName: displayName.isEmpty ? 'Membre Pointa' : displayName,
      email: (userMap['email'] as String?)?.trim() ?? '',
      phoneNumber: (userMap['phone'] as String?)?.trim().isNotEmpty == true
          ? (userMap['phone'] as String).trim()
          : fallbackPhone,
    );
  }

  Future<dynamic> _sendJson({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    String? accessToken,
  }) async {
    final client = _httpClientFactory();
    try {
      final request = await client.openUrl(method, _uriFor(path));
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      if (accessToken != null && accessToken.isNotEmpty) {
        request.headers.set(
          HttpHeaders.authorizationHeader,
          'Bearer $accessToken',
        );
      }
      if (body != null) {
        final encodedBody = utf8.encode(jsonEncode(body));
        request.headers.contentType = ContentType.json;
        request.contentLength = encodedBody.length;
        request.add(encodedBody);
      }

      final response = await request.close();
      final responseBody = await utf8.decoder.bind(response).join();
      final payload = responseBody.isEmpty ? null : jsonDecode(responseBody);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return payload;
      }

      throw AuthException(_errorMessageFromPayload(payload));
    } on SocketException {
      throw const AuthException(
        'Serveur Pointa injoignable. Verifiez l adresse API.',
      );
    } on HandshakeException {
      throw const AuthException(
        'Connexion securisee impossible avec le serveur Pointa.',
      );
    } on FormatException {
      throw const AuthException('Reponse backend invalide.');
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException('Operation impossible. Reessayez.');
    } finally {
      client.close(force: true);
    }
  }

  Uri _uriFor(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$_baseUrl$normalizedPath');
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

  String _extractUserId(String accessToken) {
    final segments = accessToken.split('.');
    if (segments.length < 2) {
      throw const AuthException('Jeton utilisateur invalide.');
    }

    final normalizedPayload = base64Url.normalize(segments[1]);
    final decodedPayload = utf8.decode(base64Url.decode(normalizedPayload));
    final payload = jsonDecode(decodedPayload);
    if (payload is! Map<String, dynamic>) {
      throw const AuthException('Jeton utilisateur invalide.');
    }

    final userId = payload['user_id']?.toString().trim();
    if (userId == null || userId.isEmpty) {
      throw const AuthException('Jeton utilisateur invalide.');
    }

    return userId;
  }

  String _errorMessageFromPayload(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final directMessage =
          payload['error']?.toString() ??
          payload['detail']?.toString() ??
          payload['message']?.toString();
      if (directMessage != null && directMessage.trim().isNotEmpty) {
        return directMessage.trim();
      }

      for (final value in payload.values) {
        final nestedMessage = _errorMessageFromPayload(value);
        if (nestedMessage.isNotEmpty) {
          return nestedMessage;
        }
      }
    }

    if (payload is List && payload.isNotEmpty) {
      final message = _errorMessageFromPayload(payload.first);
      if (message.isNotEmpty) {
        return message;
      }
    }

    final message = payload?.toString().trim();
    if (message != null && message.isNotEmpty) {
      return message;
    }

    return 'Requete backend refusee.';
  }

  _SplitName _splitName(String fullName) {
    final tokens = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .toList();

    if (tokens.isEmpty) {
      return const _SplitName(firstName: 'Utilisateur', lastName: 'Pointa');
    }

    if (tokens.length == 1) {
      return _SplitName(firstName: tokens.first, lastName: tokens.first);
    }

    return _SplitName(
      firstName: tokens.first,
      lastName: tokens.skip(1).join(' '),
    );
  }
}

class _SplitName {
  const _SplitName({required this.firstName, required this.lastName});

  final String firstName;
  final String lastName;
}
