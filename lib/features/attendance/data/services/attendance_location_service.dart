import 'package:geolocator/geolocator.dart';
import 'package:pointa_mobile/features/attendance/domain/exceptions/attendance_exception.dart';

class AttendanceLocation {
  const AttendanceLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.capturedAt,
  });

  final double latitude;
  final double longitude;
  final double accuracyMeters;
  final DateTime capturedAt;
}

class AttendanceLocationService {
  const AttendanceLocationService();

  static const _idealAccuracyMeters = 12.0;
  static const _maxAcceptedAccuracyMeters = 40.0;
  static const _captureAttempts = 3;

  Future<AttendanceLocation> getCurrentLocation() async {
    final isEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isEnabled) {
      throw const AttendanceException(
        'Activez la localisation du telephone pour pointer.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const AttendanceException(
        'Autorisez la localisation pour effectuer le pointage.',
      );
    }

    if (permission == LocationPermission.deniedForever) {
      throw const AttendanceException(
        'La localisation est refusee definitivement. Autorisez-la dans les reglages.',
      );
    }

    final position = await _readBestPosition();
    if (position.accuracy > _maxAcceptedAccuracyMeters) {
      throw AttendanceException(
        'Precision GPS insuffisante (${position.accuracy.round()} m). '
        'Rapprochez-vous d une zone degagee puis reessayez.',
      );
    }

    return AttendanceLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracyMeters: position.accuracy,
      capturedAt: DateTime.now().toUtc(),
    );
  }

  Future<Position> _readBestPosition() async {
    Position? bestPosition;
    final settings = const LocationSettings(
      accuracy: LocationAccuracy.best,
      timeLimit: Duration(seconds: 12),
    );

    for (var index = 0; index < _captureAttempts; index += 1) {
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: settings,
        );
        if (bestPosition == null || position.accuracy < bestPosition.accuracy) {
          bestPosition = position;
        }

        if (position.accuracy <= _idealAccuracyMeters) {
          break;
        }
      } catch (_) {
        continue;
      }
    }

    if (bestPosition == null) {
      throw const AttendanceException(
        'Impossible de recuperer une localisation fiable. Reessayez a l exterieur ou pres d une zone degagee.',
      );
    }

    return bestPosition;
  }
}
