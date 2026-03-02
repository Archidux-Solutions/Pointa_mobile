import 'package:pointa_mobile/features/attendance/domain/models/pending_attendance_action.dart';

class AttendanceSyncQueueDataSource {
  final List<PendingAttendanceAction> _queue = <PendingAttendanceAction>[];

  bool get isEmpty => _queue.isEmpty;

  int get count => _queue.length;

  List<PendingAttendanceAction> readQueue() =>
      List<PendingAttendanceAction>.unmodifiable(_queue);

  void enqueue(PendingAttendanceAction action) {
    _queue.insert(0, action);
  }

  void removeById(String id) {
    _queue.removeWhere((entry) => entry.id == id);
  }
}
