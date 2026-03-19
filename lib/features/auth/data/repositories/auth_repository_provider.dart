import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointa_mobile/core/network/pointa_api_client_provider.dart';
import 'package:pointa_mobile/features/auth/data/repositories/remote_auth_repository.dart';
import 'package:pointa_mobile/features/auth/domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return RemoteAuthRepository(
    apiClient: ref.watch(pointaApiClientProvider),
    sessionStore: ref.watch(apiSessionStoreProvider),
  );
});
