import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointa_mobile/core/config/data_mode.dart';
import 'package:pointa_mobile/features/attendance/data/datasources/attendance_local_data_source.dart';
import 'package:pointa_mobile/features/attendance/data/datasources/attendance_mock_data_source.dart';
import 'package:pointa_mobile/features/attendance/data/datasources/attendance_remote_data_source.dart';
import 'package:pointa_mobile/features/attendance/data/repositories/attendance_repository_impl.dart';
import 'package:pointa_mobile/features/attendance/domain/models/attendance_record.dart';
import 'package:pointa_mobile/features/attendance/domain/models/attendance_status.dart';
import 'package:pointa_mobile/features/attendance/domain/models/attendance_summary.dart';
import 'package:pointa_mobile/features/attendance/domain/repositories/attendance_repository.dart';

final dataModeProvider = Provider<DataMode>((ref) => DataMode.mock);

final attendanceLocalDataSourceProvider = Provider<AttendanceLocalDataSource>((
  ref,
) {
  return AttendanceLocalDataSource();
});

final attendanceMockDataSourceProvider = Provider<AttendanceMockDataSource>((
  ref,
) {
  return const AttendanceMockDataSource();
});

final attendanceRemoteDataSourceProvider = Provider<AttendanceRemoteDataSource>(
  (ref) {
    return const AttendanceRemoteDataSource();
  },
);

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepositoryImpl(
    mode: ref.watch(dataModeProvider),
    localDataSource: ref.watch(attendanceLocalDataSourceProvider),
    mockDataSource: ref.watch(attendanceMockDataSourceProvider),
    remoteDataSource: ref.watch(attendanceRemoteDataSourceProvider),
  );
});

final attendanceHistoryProvider = FutureProvider<List<AttendanceRecord>>((
  ref,
) async {
  return ref.watch(attendanceRepositoryProvider).getHistory();
});

final attendanceSummaryProvider = FutureProvider<AttendanceSummary>((
  ref,
) async {
  return ref.watch(attendanceRepositoryProvider).getSummary();
});

final attendanceStatusProvider = FutureProvider<AttendanceStatus>((ref) async {
  return ref.watch(attendanceRepositoryProvider).getCurrentStatus();
});
