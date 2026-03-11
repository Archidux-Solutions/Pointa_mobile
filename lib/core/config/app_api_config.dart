import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract final class AppApiConfig {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );
}

final apiBaseUrlProvider = Provider<String>((ref) {
  return AppApiConfig.baseUrl;
});
