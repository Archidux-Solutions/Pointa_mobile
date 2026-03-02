import 'package:pointa_mobile/features/attendance/domain/models/attendance_record.dart';

class PendingAttendanceAction {
  const PendingAttendanceAction({
    required this.id,
    required this.localRecordId,
    required this.actionType,
    required this.timestamp,
  });

  final String id;
  final String localRecordId;
  final AttendanceActionType actionType;
  final DateTime timestamp;
}
