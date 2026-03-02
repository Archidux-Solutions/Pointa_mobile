class AttendanceStatus {
  const AttendanceStatus({
    required this.isCheckedIn,
    required this.lastActionAt,
  });

  final bool isCheckedIn;
  final DateTime? lastActionAt;
}
