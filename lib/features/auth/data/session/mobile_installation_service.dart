import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final mobileInstallationServiceProvider = Provider<MobileInstallationService>((
  ref,
) {
  return MobileInstallationService(const FlutterSecureStorage());
});

class MobileInstallationService {
  MobileInstallationService(this._storage);

  static const _storageKey = 'pointa.mobile.installation.id';

  final FlutterSecureStorage _storage;

  Future<MobileInstallationIdentity> getIdentity() async {
    final storedValue = await _storage.read(key: _storageKey);
    final installationId =
        storedValue != null && storedValue.trim().isNotEmpty
            ? storedValue.trim()
            : await _createAndPersistInstallationId();

    return MobileInstallationIdentity(
      installationId: installationId,
      platform: Platform.operatingSystem,
    );
  }

  Future<String> _createAndPersistInstallationId() async {
    final random = Random.secure();
    final bytes = List<int>.generate(24, (_) => random.nextInt(256));
    final installationId =
        base64UrlEncode(bytes).replaceAll('=', '').replaceAll('\n', '');
    await _storage.write(key: _storageKey, value: installationId);
    return installationId;
  }
}

class MobileInstallationIdentity {
  const MobileInstallationIdentity({
    required this.installationId,
    required this.platform,
  });

  final String installationId;
  final String platform;

  Map<String, String> toHeaders() {
    return <String, String>{
      'X-Device-Installation-Id': installationId,
      'X-Device-Platform': platform,
    };
  }
}
