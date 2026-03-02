import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointa_mobile/features/attendance/application/attendance_providers.dart';
import 'package:pointa_mobile/features/attendance/domain/models/attendance_record.dart';
import 'package:pointa_mobile/features/attendance/domain/models/attendance_status.dart';
import 'package:pointa_mobile/features/attendance/domain/models/attendance_summary.dart';
import 'package:pointa_mobile/features/attendance/domain/repositories/attendance_repository.dart';

void main() {
  group('attendance_providers', () {
    test('attendanceSyncingProvider bascule correctement start/stop', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(attendanceSyncingProvider), isFalse);

      container.read(attendanceSyncingProvider.notifier).start();
      expect(container.read(attendanceSyncingProvider), isTrue);

      container.read(attendanceSyncingProvider.notifier).stop();
      expect(container.read(attendanceSyncingProvider), isFalse);
    });

    test(
      'attendancePendingSyncCountProvider lit la valeur du repository',
      () async {
        final repository = _FakeAttendanceRepository(pendingCount: 3);
        final container = ProviderContainer(
          overrides: [
            attendanceRepositoryProvider.overrideWith((ref) => repository),
          ],
        );
        addTearDown(container.dispose);

        final count = await container.read(
          attendancePendingSyncCountProvider.future,
        );

        expect(count, 3);
      },
    );
  });
}

class _FakeAttendanceRepository implements AttendanceRepository {
  _FakeAttendanceRepository({required this.pendingCount});

  final int pendingCount;

  @override
  Future<AttendanceStatus> getCurrentStatus() async {
    return const AttendanceStatus(isCheckedIn: false, lastActionAt: null);
  }

  @override
  Future<List<AttendanceRecord>> getHistory() async {
    return const <AttendanceRecord>[];
  }

  @override
  Future<int> getPendingSyncCount() async {
    return pendingCount;
  }

  @override
  Future<AttendanceSummary> getSummary() async {
    return const AttendanceSummary(
      workedMinutes: 0,
      lateCount: 0,
      absenceCount: 0,
    );
  }

  @override
  Future<int> retryPendingSync() async {
    return 0;
  }

  @override
  Future<AttendanceRecord> toggleAttendance() async {
    return AttendanceRecord(
      id: 'id',
      actionType: AttendanceActionType.checkIn,
      timestamp: DateTime(2026, 3, 2, 8, 0),
      siteLabel: 'Siege Ouaga',
    );
  }
}
