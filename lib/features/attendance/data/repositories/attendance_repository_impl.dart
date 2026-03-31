import 'package:pointa_mobile/core/config/data_mode.dart';
import 'package:pointa_mobile/features/attendance/data/datasources/attendance_local_data_source.dart';
import 'package:pointa_mobile/features/attendance/data/datasources/attendance_mock_data_source.dart';
import 'package:pointa_mobile/features/attendance/data/datasources/attendance_remote_data_source.dart';
import 'package:pointa_mobile/features/attendance/data/datasources/attendance_sync_queue_data_source.dart';
import 'package:pointa_mobile/features/attendance/data/services/attendance_location_service.dart';
import 'package:pointa_mobile/features/attendance/domain/models/attendance_record.dart';
import 'package:pointa_mobile/features/attendance/domain/models/attendance_status.dart';
import 'package:pointa_mobile/features/attendance/domain/models/attendance_summary.dart';
import 'package:pointa_mobile/features/attendance/domain/repositories/attendance_repository.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  AttendanceRepositoryImpl({
    required DataMode mode,
    required AttendanceLocalDataSource localDataSource,
    required AttendanceMockDataSource mockDataSource,
    required AttendanceRemoteDataSource remoteDataSource,
    required AttendanceSyncQueueDataSource syncQueueDataSource,
    required AttendanceLocationService locationService,
  }) : _mode = mode,
       _localDataSource = localDataSource,
       _mockDataSource = mockDataSource,
       _remoteDataSource = remoteDataSource,
       _syncQueueDataSource = syncQueueDataSource,
       _locationService = locationService;

  final DataMode _mode;
  final AttendanceLocalDataSource _localDataSource;
  final AttendanceMockDataSource _mockDataSource;
  final AttendanceRemoteDataSource _remoteDataSource;
  final AttendanceSyncQueueDataSource _syncQueueDataSource;
  final AttendanceLocationService _locationService;

  @override
  Future<AttendanceStatus> getCurrentStatus() async {
    switch (_mode) {
      case DataMode.mock:
        final history = await getHistory();
        return _statusFromHistory(history);
      case DataMode.local:
        return _statusFromHistory(_localDataSource.readRecords());
      case DataMode.remote:
        return _remoteDataSource.fetchStatus();
    }
  }

  @override
  Future<List<AttendanceRecord>> getHistory() async {
    switch (_mode) {
      case DataMode.mock:
        _seedMockHistoryIfNeeded();
        return _localDataSource.readRecords();
      case DataMode.local:
        return _localDataSource.readRecords();
      case DataMode.remote:
        final remoteHistory = await _remoteDataSource.fetchHistory();
        _localDataSource.replaceRecords(remoteHistory);
        return _localDataSource.readRecords();
    }
  }

  @override
  Future<AttendanceSummary> getSummary() async {
    switch (_mode) {
      case DataMode.mock:
        final history = await getHistory();
        return AttendanceSummary(
          workedMinutes: _calculateWorkedMinutes(history),
          lateCount: _mockDataSource.seedLateCount,
          absenceCount: _mockDataSource.seedAbsenceCount,
        );
      case DataMode.local:
        final history = await getHistory();
        return AttendanceSummary(
          workedMinutes: _calculateWorkedMinutes(history),
          lateCount: 0,
          absenceCount: 0,
        );
      case DataMode.remote:
        return _remoteDataSource.fetchSummary();
    }
  }

  @override
  Future<AttendanceRecord> toggleAttendance() async {
    final status = await getCurrentStatus();
    final nextAction = status.isCheckedIn
        ? AttendanceActionType.checkOut
        : AttendanceActionType.checkIn;

    if (_mode == DataMode.remote) {
      final location = await _locationService.getCurrentLocation();
      final record = await _remoteDataSource.sendToggle(
        latitude: location.latitude,
        longitude: location.longitude,
        accuracyMeters: location.accuracyMeters,
        capturedAt: location.capturedAt,
      );
      _localDataSource.addRecord(record);
      return record;
    }

    final now = DateTime.now();
    final record = AttendanceRecord(
      id: 'local-${now.microsecondsSinceEpoch}',
      actionType: nextAction,
      timestamp: now,
      siteLabel: 'Siege Ouaga',
    );
    _localDataSource.addRecord(record);
    return record;
  }

  @override
  Future<int> getPendingSyncCount() async {
    if (_mode == DataMode.remote) {
      return 0;
    }

    return _syncQueueDataSource.count;
  }

  @override
  Future<int> retryPendingSync() async {
    return 0;
  }

  void _seedMockHistoryIfNeeded() {
    if (!_localDataSource.isEmpty) {
      return;
    }

    _localDataSource.replaceRecords(_mockDataSource.seedHistory());
  }

  AttendanceStatus _statusFromHistory(List<AttendanceRecord> history) {
    if (history.isEmpty) {
      return const AttendanceStatus(isCheckedIn: false, lastActionAt: null);
    }

    final latest = history.first;
    return AttendanceStatus(
      isCheckedIn: latest.actionType == AttendanceActionType.checkIn,
      lastActionAt: latest.timestamp,
      siteLabel: latest.siteLabel,
    );
  }

  int _calculateWorkedMinutes(List<AttendanceRecord> history) {
    if (history.isEmpty) {
      return 0;
    }

    final chronological = List<AttendanceRecord>.from(history)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    DateTime? openCheckIn;
    var workedMinutes = 0;

    for (final record in chronological) {
      if (record.actionType == AttendanceActionType.checkIn) {
        openCheckIn = record.timestamp;
        continue;
      }

      if (openCheckIn == null) {
        continue;
      }

      if (record.timestamp.isAfter(openCheckIn)) {
        workedMinutes += record.timestamp.difference(openCheckIn).inMinutes;
      }
      openCheckIn = null;
    }

    return workedMinutes;
  }
}
