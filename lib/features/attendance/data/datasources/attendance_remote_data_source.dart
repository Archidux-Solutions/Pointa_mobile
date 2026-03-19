import 'package:pointa_mobile/core/network/api_exception.dart';
import 'package:pointa_mobile/core/network/pointa_api_client.dart';
import 'package:pointa_mobile/features/attendance/domain/exceptions/attendance_exception.dart';
import 'package:pointa_mobile/features/attendance/domain/models/attendance_record.dart';
import 'package:pointa_mobile/features/attendance/domain/models/attendance_status.dart';
import 'package:pointa_mobile/features/attendance/domain/models/attendance_summary.dart';

class AttendanceRemoteDataSource {
  const AttendanceRemoteDataSource({required PointaApiClient apiClient})
    : _apiClient = apiClient;

  final PointaApiClient _apiClient;

  Future<AttendanceStatus> fetchStatus() async {
    try {
      final payload = await _apiClient.sendJson(
        method: 'GET',
        path: '/api/today/',
        authenticated: true,
      );

      if (payload is! Map<String, dynamic>) {
        throw const AttendanceException('Statut de pointage indisponible.');
      }

      final checkedIn = payload['checked_in'] == true;
      final checkInAt = _readDateTime(payload['check_in_time']);
      final checkOutAt = _readDateTime(payload['check_out_time']);
      final site = payload['site'];
      final siteLabel = site is Map<String, dynamic>
          ? (site['name']?.toString().trim().isNotEmpty == true
                ? site['name'].toString().trim()
                : 'Site principal')
          : 'Site principal';
      final radiusMeters = site is Map<String, dynamic>
          ? int.tryParse('${site['radius_meters'] ?? ''}')
          : null;

      return AttendanceStatus(
        isCheckedIn: checkedIn,
        lastActionAt: checkedIn ? checkInAt : (checkOutAt ?? checkInAt),
        siteLabel: siteLabel,
        radiusMeters: radiusMeters,
      );
    } on ApiException catch (error) {
      throw AttendanceException(error.message);
    }
  }

  Future<List<AttendanceRecord>> fetchHistory() async {
    try {
      final payload = await _apiClient.sendJson(
        method: 'GET',
        path: '/api/history/',
        authenticated: true,
      );

      if (payload is! List) {
        throw const AttendanceException('Historique de pointage indisponible.');
      }

      final records = <AttendanceRecord>[];
      for (final item in payload.whereType<Map<String, dynamic>>()) {
        final attendanceId = '${item['id'] ?? ''}'.trim();
        final site = item['site'];
        final siteLabel = site is Map<String, dynamic>
            ? (site['name']?.toString().trim().isNotEmpty == true
                  ? site['name'].toString().trim()
                  : 'Site principal')
            : 'Site principal';
        final checkInAt = _readDateTime(item['check_in']);
        final checkOutAt = _readDateTime(item['check_out']);

        if (checkInAt != null) {
          records.add(
            AttendanceRecord(
              id: attendanceId.isEmpty
                  ? 'attendance-${checkInAt.microsecondsSinceEpoch}-in'
                  : '$attendanceId-in',
              actionType: AttendanceActionType.checkIn,
              timestamp: checkInAt,
              siteLabel: siteLabel,
            ),
          );
        }

        if (checkOutAt != null) {
          records.add(
            AttendanceRecord(
              id: attendanceId.isEmpty
                  ? 'attendance-${checkOutAt.microsecondsSinceEpoch}-out'
                  : '$attendanceId-out',
              actionType: AttendanceActionType.checkOut,
              timestamp: checkOutAt,
              siteLabel: siteLabel,
            ),
          );
        }
      }

      records.sort((left, right) => right.timestamp.compareTo(left.timestamp));
      return records;
    } on ApiException catch (error) {
      throw AttendanceException(error.message);
    }
  }

  Future<AttendanceSummary> fetchSummary() async {
    try {
      final payload = await _apiClient.sendJson(
        method: 'GET',
        path: '/api/dashboard/stats/',
        authenticated: true,
      );

      if (payload is! Map<String, dynamic>) {
        throw const AttendanceException('Recap de pointage indisponible.');
      }

      return AttendanceSummary(
        workedMinutes: _readRequiredInt(payload, 'worked_minutes'),
        lateCount: _readRequiredInt(payload, 'late_days'),
        absenceCount: _readRequiredInt(payload, 'absent_days'),
      );
    } on ApiException catch (error) {
      throw AttendanceException(error.message);
    }
  }

  Future<AttendanceRecord> sendToggle({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final payload = await _apiClient.sendJson(
        method: 'POST',
        path: '/api/attendances/punch/',
        body: <String, dynamic>{'latitude': latitude, 'longitude': longitude},
        authenticated: true,
      );

      if (payload is! Map<String, dynamic>) {
        throw const AttendanceException('Pointage impossible.');
      }

      final action = payload['action']?.toString().trim();
      final attendance = payload['attendance'];
      final site = payload['site'];
      if (action == null ||
          action.isEmpty ||
          attendance is! Map<String, dynamic>) {
        throw const AttendanceException('Reponse de pointage incomplete.');
      }

      final siteLabel = site is Map<String, dynamic>
          ? (site['name']?.toString().trim().isNotEmpty == true
                ? site['name'].toString().trim()
                : 'Site principal')
          : 'Site principal';
      final actionType = action == 'check_out'
          ? AttendanceActionType.checkOut
          : AttendanceActionType.checkIn;
      final timestamp = actionType == AttendanceActionType.checkOut
          ? _readDateTime(attendance['check_out'])
          : _readDateTime(attendance['check_in']);

      if (timestamp == null) {
        throw const AttendanceException('Heure de pointage introuvable.');
      }

      final attendanceId = '${attendance['id'] ?? ''}'.trim();
      return AttendanceRecord(
        id: attendanceId.isEmpty
            ? 'attendance-${timestamp.microsecondsSinceEpoch}'
            : '$attendanceId-${actionType == AttendanceActionType.checkIn ? 'in' : 'out'}',
        actionType: actionType,
        timestamp: timestamp,
        siteLabel: siteLabel,
      );
    } on ApiException catch (error) {
      throw AttendanceException(error.message);
    }
  }

  DateTime? _readDateTime(dynamic value) {
    final raw = value?.toString().trim();
    if (raw == null || raw.isEmpty) {
      return null;
    }

    return DateTime.tryParse(raw)?.toLocal();
  }

  int _readRequiredInt(Map<String, dynamic> payload, String key) {
    final value = payload[key];
    if (value is int) {
      return value;
    }

    return int.tryParse('${value ?? ''}') ?? 0;
  }
}
