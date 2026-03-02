import 'dart:async';

import 'package:pointa_mobile/features/attendance/domain/models/attendance_record.dart';

class AttendanceRemoteDataSource {
  const AttendanceRemoteDataSource();

  Future<List<AttendanceRecord>> fetchHistory() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return const <AttendanceRecord>[];
  }

  Future<AttendanceRecord> sendToggle({
    required AttendanceActionType nextAction,
    required DateTime at,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return AttendanceRecord(
      id: 'remote-${at.microsecondsSinceEpoch}',
      actionType: nextAction,
      timestamp: at,
      siteLabel: 'Site distant',
    );
  }
}
