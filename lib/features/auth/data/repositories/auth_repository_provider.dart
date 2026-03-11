import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointa_mobile/core/config/app_api_config.dart';
import 'package:pointa_mobile/features/auth/data/repositories/remote_auth_repository.dart';
import 'package:pointa_mobile/features/auth/domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return RemoteAuthRepository(baseUrl: ref.watch(apiBaseUrlProvider));
});
