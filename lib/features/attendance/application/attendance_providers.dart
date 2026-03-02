import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointa_mobile/core/config/data_mode.dart';
import 'package:pointa_mobile/features/attendance/data/datasources/attendance_local_data_source.dart';
import 'package:pointa_mobile/features/attendance/data/datasources/attendance_mock_data_source.dart';
import 'package:pointa_mobile/features/attendance/data/datasources/attendance_remote_data_source.dart';
import 'package:pointa_mobile/features/attendance/data/datasources/attendance_sync_queue_data_source.dart';
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

final attendanceSyncQueueDataSourceProvider =
    Provider<AttendanceSyncQueueDataSource>((ref) {
      return AttendanceSyncQueueDataSource();
    });

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepositoryImpl(
    mode: ref.watch(dataModeProvider),
    localDataSource: ref.watch(attendanceLocalDataSourceProvider),
    mockDataSource: ref.watch(attendanceMockDataSourceProvider),
    remoteDataSource: ref.watch(attendanceRemoteDataSourceProvider),
    syncQueueDataSource: ref.watch(attendanceSyncQueueDataSourceProvider),
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

final attendancePendingSyncCountProvider = FutureProvider<int>((ref) async {
  return ref.watch(attendanceRepositoryProvider).getPendingSyncCount();
});

final attendanceSyncingProvider =
    NotifierProvider<AttendanceSyncingNotifier, bool>(
      AttendanceSyncingNotifier.new,
    );

void refreshAttendanceReadModels(WidgetRef ref) {
  ref.invalidate(attendanceStatusProvider);
  ref.invalidate(attendanceHistoryProvider);
  ref.invalidate(attendanceSummaryProvider);
  ref.invalidate(attendancePendingSyncCountProvider);
}

Future<int> retryPendingAttendanceSync(WidgetRef ref) async {
  ref.read(attendanceSyncingProvider.notifier).start();
  try {
    final synced = await ref
        .read(attendanceRepositoryProvider)
        .retryPendingSync();
    refreshAttendanceReadModels(ref);
    return synced;
  } finally {
    ref.read(attendanceSyncingProvider.notifier).stop();
  }
}

class AttendanceSyncingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void start() {
    state = true;
  }

  void stop() {
    state = false;
  }
}
