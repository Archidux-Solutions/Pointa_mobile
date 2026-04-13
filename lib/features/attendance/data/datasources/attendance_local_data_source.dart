import 'package:pointa_mobile/features/attendance/domain/models/attendance_record.dart';

class AttendanceLocalDataSource {
  final List<AttendanceRecord> _records = <AttendanceRecord>[];

  bool get isEmpty => _records.isEmpty;

  List<AttendanceRecord> readRecords() =>
      List<AttendanceRecord>.unmodifiable(_records);

  void replaceRecords(List<AttendanceRecord> records) {
    _records
      ..clear()
      ..addAll(records);
  }

  void addRecord(AttendanceRecord record) {
    _records.insert(0, record);
  }

  void clear() {
    _records.clear();
  }

  void replaceRecordById({
    required String id,
    required AttendanceRecord record,
  }) {
    final index = _records.indexWhere((entry) => entry.id == id);
    if (index == -1) {
      _records.insert(0, record);
      return;
    }
    _records[index] = record;
  }
}
