import 'package:flutter_test/flutter_test.dart';
import 'package:pointa_mobile/core/config/data_mode.dart';
import 'package:pointa_mobile/core/network/api_session_store.dart';
import 'package:pointa_mobile/core/network/pointa_api_client.dart';
import 'package:pointa_mobile/features/attendance/data/datasources/attendance_local_data_source.dart';
import 'package:pointa_mobile/features/attendance/data/datasources/attendance_mock_data_source.dart';
import 'package:pointa_mobile/features/attendance/data/datasources/attendance_remote_data_source.dart';
import 'package:pointa_mobile/features/attendance/data/datasources/attendance_sync_queue_data_source.dart';
import 'package:pointa_mobile/features/attendance/data/repositories/attendance_repository_impl.dart';
import 'package:pointa_mobile/features/attendance/data/services/attendance_location_service.dart';
import 'package:pointa_mobile/features/attendance/domain/models/attendance_record.dart';
import 'package:pointa_mobile/features/attendance/domain/models/attendance_status.dart';
import 'package:pointa_mobile/features/attendance/domain/models/attendance_summary.dart';

void main() {
  group('AttendanceRepositoryImpl', () {
    test('charge un historique seed en mode mock', () async {
      final repository = AttendanceRepositoryImpl(
        mode: DataMode.mock,
        localDataSource: AttendanceLocalDataSource(),
        mockDataSource: const AttendanceMockDataSource(),
        remoteDataSource: _unusedRemoteDataSource(),
        syncQueueDataSource: AttendanceSyncQueueDataSource(),
        locationService: const AttendanceLocationService(),
      );

      final history = await repository.getHistory();

      expect(history, isNotEmpty);
    });

    test('toggleAttendance inverse le statut courant', () async {
      final repository = AttendanceRepositoryImpl(
        mode: DataMode.mock,
        localDataSource: AttendanceLocalDataSource(),
        mockDataSource: const AttendanceMockDataSource(),
        remoteDataSource: _unusedRemoteDataSource(),
        syncQueueDataSource: AttendanceSyncQueueDataSource(),
        locationService: const AttendanceLocationService(),
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
        remoteDataSource: _unusedRemoteDataSource(),
        syncQueueDataSource: AttendanceSyncQueueDataSource(),
        locationService: const AttendanceLocationService(),
      );

      final summary = await repository.getSummary();

      expect(summary.workedMinutes, 540);
      expect(summary.lateCount, 0);
      expect(summary.absenceCount, 0);
    });

    test('utilise le backend reel en mode remote', () async {
      final remoteDataSource = _ConfigurableRemoteDataSource();
      final repository = AttendanceRepositoryImpl(
        mode: DataMode.remote,
        localDataSource: AttendanceLocalDataSource(),
        mockDataSource: const AttendanceMockDataSource(),
        remoteDataSource: remoteDataSource,
        syncQueueDataSource: AttendanceSyncQueueDataSource(),
        locationService: const _FakeLocationService(),
      );

      final status = await repository.getCurrentStatus();
      final record = await repository.toggleAttendance();
      final history = await repository.getHistory();
      final summary = await repository.getSummary();

      expect(status.isCheckedIn, isFalse);
      expect(record.actionType, AttendanceActionType.checkIn);
      expect(history, isNotEmpty);
      expect(summary, isA<AttendanceSummary>());
      expect(remoteDataSource.toggleCalls, 1);
      expect(remoteDataSource.historyCalls, greaterThanOrEqualTo(1));
      expect(summary.workedMinutes, 480);
      expect(summary.lateCount, 1);
      expect(summary.absenceCount, 0);
    });
  });
}

AttendanceRemoteDataSource _unusedRemoteDataSource() {
  return AttendanceRemoteDataSource(
    apiClient: PointaApiClient(
      baseUrl: 'http://127.0.0.1:8000',
      sessionStore: ApiSessionStore(),
    ),
  );
}

class _FakeLocationService extends AttendanceLocationService {
  const _FakeLocationService();

  @override
  Future<AttendanceLocation> getCurrentLocation() async {
    return const AttendanceLocation(latitude: 12.34, longitude: -1.56);
  }
}

class _ConfigurableRemoteDataSource extends AttendanceRemoteDataSource {
  _ConfigurableRemoteDataSource()
    : super(
        apiClient: PointaApiClient(
          baseUrl: 'http://127.0.0.1:8000',
          sessionStore: ApiSessionStore(),
        ),
      );

  int historyCalls = 0;
  int toggleCalls = 0;

  @override
  Future<AttendanceStatus> fetchStatus() async {
    return const AttendanceStatus(
      isCheckedIn: false,
      lastActionAt: null,
      siteLabel: 'Site distant',
      radiusMeters: 120,
    );
  }

  @override
  Future<List<AttendanceRecord>> fetchHistory() async {
    historyCalls++;
    return <AttendanceRecord>[
      AttendanceRecord(
        id: 'remote-out',
        actionType: AttendanceActionType.checkOut,
        timestamp: DateTime(2026, 3, 2, 17, 0),
        siteLabel: 'Site distant',
      ),
      AttendanceRecord(
        id: 'remote-in',
        actionType: AttendanceActionType.checkIn,
        timestamp: DateTime(2026, 3, 2, 8, 0),
        siteLabel: 'Site distant',
      ),
    ];
  }

  @override
  Future<AttendanceSummary> fetchSummary() async {
    return const AttendanceSummary(
      workedMinutes: 480,
      lateCount: 1,
      absenceCount: 0,
    );
  }

  @override
  Future<AttendanceRecord> sendToggle({
    required double latitude,
    required double longitude,
  }) async {
    toggleCalls++;
    return AttendanceRecord(
      id: 'remote-toggle-$toggleCalls',
      actionType: AttendanceActionType.checkIn,
      timestamp: DateTime(2026, 3, 3, 8, 5),
      siteLabel: 'Site distant',
    );
  }
}
