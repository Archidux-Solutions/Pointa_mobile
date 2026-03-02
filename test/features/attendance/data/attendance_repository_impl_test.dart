import 'package:flutter_test/flutter_test.dart';
import 'package:pointa_mobile/core/config/data_mode.dart';
import 'package:pointa_mobile/features/attendance/data/datasources/attendance_local_data_source.dart';
import 'package:pointa_mobile/features/attendance/data/datasources/attendance_mock_data_source.dart';
import 'package:pointa_mobile/features/attendance/data/datasources/attendance_remote_data_source.dart';
import 'package:pointa_mobile/features/attendance/data/repositories/attendance_repository_impl.dart';
import 'package:pointa_mobile/features/attendance/domain/models/attendance_record.dart';

void main() {
  group('AttendanceRepositoryImpl', () {
    test('charge un historique seed en mode mock', () async {
      final repository = AttendanceRepositoryImpl(
        mode: DataMode.mock,
        localDataSource: AttendanceLocalDataSource(),
        mockDataSource: const AttendanceMockDataSource(),
        remoteDataSource: const AttendanceRemoteDataSource(),
      );

      final history = await repository.getHistory();

      expect(history, isNotEmpty);
    });

    test('toggleAttendance inverse le statut courant', () async {
      final repository = AttendanceRepositoryImpl(
        mode: DataMode.mock,
        localDataSource: AttendanceLocalDataSource(),
        mockDataSource: const AttendanceMockDataSource(),
        remoteDataSource: const AttendanceRemoteDataSource(),
      );

      final before = await repository.getCurrentStatus();
      final record = await repository.toggleAttendance();
      final after = await repository.getCurrentStatus();

      expect(
        record.actionType,
        before.isCheckedIn
            ? AttendanceActionType.checkOut
            : AttendanceActionType.checkIn,
      );
      expect(after.isCheckedIn, isNot(before.isCheckedIn));
    });

    test('retourne un resume coherent en mode local', () async {
      final localDataSource = AttendanceLocalDataSource()
        ..replaceRecords(<AttendanceRecord>[
          AttendanceRecord(
            id: 'out',
            actionType: AttendanceActionType.checkOut,
            timestamp: DateTime(2026, 3, 2, 17, 0),
            siteLabel: 'Site',
          ),
          AttendanceRecord(
            id: 'in',
            actionType: AttendanceActionType.checkIn,
            timestamp: DateTime(2026, 3, 2, 8, 0),
            siteLabel: 'Site',
          ),
        ]);

      final repository = AttendanceRepositoryImpl(
        mode: DataMode.local,
        localDataSource: localDataSource,
        mockDataSource: const AttendanceMockDataSource(),
        remoteDataSource: const AttendanceRemoteDataSource(),
      );

      final summary = await repository.getSummary();

      expect(summary.workedMinutes, 540);
      expect(summary.lateCount, 0);
      expect(summary.absenceCount, 0);
    });
  });
}
