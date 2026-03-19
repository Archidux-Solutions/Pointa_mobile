import 'dart:convert';
import 'dart:io';

import 'package:pointa_mobile/core/network/api_exception.dart';
import 'package:pointa_mobile/core/network/api_session_store.dart';

class PointaApiClient {
  PointaApiClient({
    required String baseUrl,
    required ApiSessionStore sessionStore,
    HttpClient Function()? httpClientFactory,
  }) : _baseUrl = baseUrl.trim().replaceFirst(RegExp(r'/$'), ''),
       _sessionStore = sessionStore,
       _httpClientFactory = httpClientFactory ?? HttpClient.new;

  final String _baseUrl;
  final ApiSessionStore _sessionStore;
  final HttpClient Function() _httpClientFactory;

  Future<dynamic> sendJson({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    bool authenticated = false,
    String? accessTokenOverride,
    bool allowRefresh = true,
  }) async {
    try {
      final authToken = authenticated
          ? accessTokenOverride ?? _sessionStore.accessToken
          : accessTokenOverride;
      if (authenticated && (authToken == null || authToken.isEmpty)) {
        throw const ApiException('Session expiree. Reconnectez-vous.');
      }

      final response = await _executeJson(
        method: method,
        path: path,
        body: body,
        accessToken: authToken,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.payload;
      }

      if (response.statusCode == 401 &&
          authenticated &&
          allowRefresh &&
          accessTokenOverride == null) {
        final refreshed = await _tryRefreshToken();
        if (refreshed) {
          return sendJson(
            method: method,
            path: path,
            body: body,
            authenticated: true,
            allowRefresh: false,
          );
        }
      }

      throw ApiException(
        _errorMessageFromPayload(response.payload),
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw const ApiException(
        'Serveur Pointa injoignable. Verifiez l adresse API.',
      );
    } on HandshakeException {
      throw const ApiException(
        'Connexion securisee impossible avec le serveur Pointa.',
      );
    } on FormatException {
      throw const ApiException('Reponse backend invalide.');
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('Operation impossible. Reessayez.');
    }
  }

  Future<bool> _tryRefreshToken() async {
    final refreshToken = _sessionStore.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) {
      _sessionStore.clear();
      return false;
    }

    try {
      final response = await _executeJson(
        method: 'POST',
        path: '/api/auth/token/refresh/',
        body: <String, dynamic>{'refresh': refreshToken},
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        _sessionStore.clear();
        return false;
      }

      final payload = response.payload;
      if (payload is! Map<String, dynamic>) {
        _sessionStore.clear();
        return false;
      }

      final accessToken = payload['access']?.toString().trim();
      if (accessToken == null || accessToken.isEmpty) {
        _sessionStore.clear();
        return false;
      }

      _sessionStore.update(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      return true;
    } catch (_) {
      _sessionStore.clear();
      return false;
    }
  }

  Future<_ApiResponse> _executeJson({
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

      return _ApiResponse(statusCode: response.statusCode, payload: payload);
    } finally {
      client.close(force: true);
    }
  }

  Uri _uriFor(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$_baseUrl$normalizedPath');
  }

  String _errorMessageFromPayload(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      for (final key in <String>['error', 'detail', 'message']) {
        final value = payload[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }

      for (final entry in payload.entries) {
        final value = entry.value;
        if (value is List && value.isNotEmpty) {
          return value.first.toString();
        }
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
    }

    if (payload is List && payload.isNotEmpty) {
      return payload.first.toString();
    }

    return 'Operation impossible. Reessayez.';
  }
}

class _ApiResponse {
  const _ApiResponse({required this.statusCode, required this.payload});

  final int statusCode;
  final dynamic payload;
}
