enum AttendanceActionType { checkIn, checkOut }

class AttendanceRecord {
  const AttendanceRecord({
    required this.id,
    required this.actionType,
    required this.timestamp,
    required this.siteLabel,
    this.isPendingSync = false,
  });

  final String id;
  final AttendanceActionType actionType;
  final DateTime timestamp;
  final String siteLabel;
  final bool isPendingSync;
}
