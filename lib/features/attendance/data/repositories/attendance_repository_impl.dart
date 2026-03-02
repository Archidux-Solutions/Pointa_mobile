import 'package:pointa_mobile/core/config/data_mode.dart';
import 'package:pointa_mobile/features/attendance/data/datasources/attendance_local_data_source.dart';
import 'package:pointa_mobile/features/attendance/data/datasources/attendance_mock_data_source.dart';
import 'package:pointa_mobile/features/attendance/data/datasources/attendance_remote_data_source.dart';
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
  }) : _mode = mode,
       _localDataSource = localDataSource,
       _mockDataSource = mockDataSource,
       _remoteDataSource = remoteDataSource;

  final DataMode _mode;
  final AttendanceLocalDataSource _localDataSource;
  final AttendanceMockDataSource _mockDataSource;
  final AttendanceRemoteDataSource _remoteDataSource;

  @override
  Future<AttendanceStatus> getCurrentStatus() async {
    final history = await getHistory();
    if (history.isEmpty) {
      return const AttendanceStatus(isCheckedIn: false, lastActionAt: null);
    }

    final latest = history.first;
    return AttendanceStatus(
      isCheckedIn: latest.actionType == AttendanceActionType.checkIn,
      lastActionAt: latest.timestamp,
    );
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
        if (remoteHistory.isNotEmpty) {
          _localDataSource.replaceRecords(remoteHistory);
        }
        return _localDataSource.readRecords();
    }
  }

  @override
  Future<AttendanceSummary> getSummary() async {
    final history = await getHistory();

    final workedMinutes = _calculateWorkedMinutes(history);
    final lateCount = _mode == DataMode.mock
        ? _mockDataSource.seedLateCount
        : 0;
    final absenceCount = _mode == DataMode.mock
        ? _mockDataSource.seedAbsenceCount
        : 0;

    return AttendanceSummary(
      workedMinutes: workedMinutes,
      lateCount: lateCount,
      absenceCount: absenceCount,
    );
  }

  @override
  Future<AttendanceRecord> toggleAttendance() async {
    final status = await getCurrentStatus();
    final nextAction = status.isCheckedIn
        ? AttendanceActionType.checkOut
        : AttendanceActionType.checkIn;
    final now = DateTime.now();

    late final AttendanceRecord record;
    if (_mode == DataMode.remote) {
      record = await _remoteDataSource.sendToggle(
        nextAction: nextAction,
        at: now,
      );
    } else {
      record = AttendanceRecord(
        id: 'local-${now.microsecondsSinceEpoch}',
        actionType: nextAction,
        timestamp: now,
        siteLabel: 'Siege Ouaga',
      );
    }

    _localDataSource.addRecord(record);
    return record;
  }

  void _seedMockHistoryIfNeeded() {
    if (!_localDataSource.isEmpty) {
      return;
    }

    _localDataSource.replaceRecords(_mockDataSource.seedHistory());
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
