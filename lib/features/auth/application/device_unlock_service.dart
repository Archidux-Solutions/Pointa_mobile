import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

final deviceUnlockServiceProvider = Provider<DeviceUnlockService>((ref) {
  return DeviceUnlockService(LocalAuthentication());
});

class DeviceUnlockService {
  const DeviceUnlockService(this._localAuthentication);

  final LocalAuthentication _localAuthentication;

  Future<bool> isDeviceSecurityAvailable() async {
    try {
      return await _localAuthentication.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  Future<bool> requestUnlock() async {
    try {
      return await _localAuthentication.authenticate(
        localizedReason: 'Deverrouillez Pointa pour continuer.',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          sensitiveTransaction: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
