import 'package:pointa_mobile/features/attendance/domain/models/attendance_record.dart';

class AttendanceMockDataSource {
  const AttendanceMockDataSource();

  List<AttendanceRecord> seedHistory() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    final yesterdayCheckIn = DateTime(
      yesterday.year,
      yesterday.month,
      yesterday.day,
      8,
      6,
    );
    final yesterdayCheckOut = DateTime(
      yesterday.year,
      yesterday.month,
      yesterday.day,
      17,
      4,
    );
    final todayCheckIn = DateTime(now.year, now.month, now.day, 8, 12);

    return <AttendanceRecord>[
      AttendanceRecord(
        id: 'mock-today-in',
        actionType: AttendanceActionType.checkIn,
        timestamp: todayCheckIn,
        siteLabel: 'Siege Ouaga',
      ),
      AttendanceRecord(
        id: 'mock-yesterday-out',
        actionType: AttendanceActionType.checkOut,
        timestamp: yesterdayCheckOut,
        siteLabel: 'Siege Ouaga',
      ),
      AttendanceRecord(
        id: 'mock-yesterday-in',
        actionType: AttendanceActionType.checkIn,
        timestamp: yesterdayCheckIn,
        siteLabel: 'Siege Ouaga',
      ),
    ];
  }

  int get seedLateCount => 1;

  int get seedAbsenceCount => 0;
}
