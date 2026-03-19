import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointa_mobile/core/config/app_api_config.dart';
import 'package:pointa_mobile/core/network/api_session_store.dart';
import 'package:pointa_mobile/core/network/pointa_api_client.dart';

final apiSessionStoreProvider = Provider<ApiSessionStore>((ref) {
  final store = ApiSessionStore();
  ref.onDispose(store.clear);
  return store;
});

final pointaApiClientProvider = Provider<PointaApiClient>((ref) {
  return PointaApiClient(
    baseUrl: ref.watch(apiBaseUrlProvider),
    sessionStore: ref.watch(apiSessionStoreProvider),
  );
});
