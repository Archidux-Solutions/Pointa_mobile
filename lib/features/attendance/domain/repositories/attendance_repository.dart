import 'package:pointa_mobile/features/attendance/domain/models/attendance_record.dart';
import 'package:pointa_mobile/features/attendance/domain/models/attendance_status.dart';
import 'package:pointa_mobile/features/attendance/domain/models/attendance_summary.dart';

abstract class AttendanceRepository {
  Future<AttendanceStatus> getCurrentStatus();

  Future<List<AttendanceRecord>> getHistory();

  Future<AttendanceSummary> getSummary();

  Future<AttendanceRecord> toggleAttendance();

  Future<int> getPendingSyncCount();

  Future<int> retryPendingSync();
}
