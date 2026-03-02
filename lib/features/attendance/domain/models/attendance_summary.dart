class AttendanceSummary {
  const AttendanceSummary({
    required this.workedMinutes,
    required this.lateCount,
    required this.absenceCount,
  });

  final int workedMinutes;
  final int lateCount;
  final int absenceCount;
}
