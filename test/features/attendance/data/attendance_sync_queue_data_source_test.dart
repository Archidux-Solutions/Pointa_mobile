import 'package:flutter_test/flutter_test.dart';
import 'package:pointa_mobile/features/attendance/data/datasources/attendance_sync_queue_data_source.dart';
import 'package:pointa_mobile/features/attendance/domain/models/attendance_record.dart';
import 'package:pointa_mobile/features/attendance/domain/models/pending_attendance_action.dart';

void main() {
  group('AttendanceSyncQueueDataSource', () {
    test('enqueue puis removeById met a jour la queue', () {
      final queue = AttendanceSyncQueueDataSource();
      final action = PendingAttendanceAction(
        id: 'queue-1',
        localRecordId: 'local-1',
        actionType: AttendanceActionType.checkIn,
        timestamp: DateTime(2026, 3, 2, 8, 0),
      );

      queue.enqueue(action);
      expect(queue.count, 1);
      expect(queue.isEmpty, isFalse);

      queue.removeById('queue-1');
      expect(queue.count, 0);
      expect(queue.isEmpty, isTrue);
    });
  });
}
