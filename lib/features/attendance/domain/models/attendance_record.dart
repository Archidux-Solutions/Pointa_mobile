enum AttendanceActionType { checkIn, checkOut }

class AttendanceRecord {
  const AttendanceRecord({
    required this.id,
    required this.actionType,
    required this.timestamp,
    required this.siteLabel,
  });

  final String id;
  final AttendanceActionType actionType;
  final DateTime timestamp;
  final String siteLabel;
}
