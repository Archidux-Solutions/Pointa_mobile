import 'package:geolocator/geolocator.dart';
import 'package:pointa_mobile/features/attendance/domain/exceptions/attendance_exception.dart';

class AttendanceLocation {
  const AttendanceLocation({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

class AttendanceLocationService {
  const AttendanceLocationService();

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

    final position = await Geolocator.getCurrentPosition();
    return AttendanceLocation(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}
