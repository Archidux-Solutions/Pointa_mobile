class AttendanceStatus {
  const AttendanceStatus({
    required this.isCheckedIn,
    required this.lastActionAt,
    this.siteLabel = 'Site principal',
    this.radiusMeters,
  });

  final bool isCheckedIn;
  final DateTime? lastActionAt;
  final String siteLabel;
  final int? radiusMeters;
}
