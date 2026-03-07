import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointa_mobile/features/attendance/application/attendance_providers.dart';
import 'package:pointa_mobile/features/attendance/domain/models/attendance_record.dart';
import 'package:pointa_mobile/features/attendance/domain/models/attendance_status.dart';
import 'package:pointa_mobile/features/attendance/domain/models/attendance_summary.dart';
import 'package:pointa_mobile/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:pointa_mobile/features/attendance/presentation/pages/attendance_page.dart';

void main() {
  group('AttendancePage', () {
    testWidgets('affiche etat synchronise quand aucune action en attente', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            attendanceStatusProvider.overrideWith(
              (ref) async => const AttendanceStatus(
                isCheckedIn: false,
                lastActionAt: null,
              ),
            ),
            attendanceHistoryProvider.overrideWith((ref) async {
              return <AttendanceRecord>[
                AttendanceRecord(
                  id: 'record-1',
                  actionType: AttendanceActionType.checkIn,
                  timestamp: DateTime(2026, 3, 2, 8, 0),
                  siteLabel: 'Siege Ouaga',
                ),
              ];
            }),
            attendancePendingSyncCountProvider.overrideWith((ref) async => 0),
          ],
          child: const MaterialApp(home: AttendancePage()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Pointage'), findsWidgets);
      expect(find.text('Historique du jour'), findsOneWidget);
      expect(find.text("Pointer l'arrivee"), findsOneWidget);
      expect(find.text('Synchroniser maintenant'), findsNothing);
      expect(find.text('Synchroniser'), findsNothing);
    });

    testWidgets('declenche retry sync et affiche le resultat', (
      WidgetTester tester,
    ) async {
      final repository = _RetryFakeAttendanceRepository(retryResult: 2);

      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            attendanceRepositoryProvider.overrideWith((ref) => repository),
            attendanceStatusProvider.overrideWith(
              (ref) async => const AttendanceStatus(
                isCheckedIn: false,
                lastActionAt: null,
              ),
            ),
            attendanceHistoryProvider.overrideWith((ref) async {
              return <AttendanceRecord>[
                AttendanceRecord(
                  id: 'record-1',
                  actionType: AttendanceActionType.checkIn,
                  timestamp: DateTime(2026, 3, 2, 8, 0),
                  siteLabel: 'Siege Ouaga',
                ),
              ];
            }),
            attendancePendingSyncCountProvider.overrideWith((ref) async => 2),
          ],
          child: const MaterialApp(home: AttendancePage()),
        ),
      );

      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Synchroniser'));
      await tester.tap(find.text('Synchroniser'));
      await tester.pumpAndSettle();

      expect(repository.retryCalls, 1);
      expect(find.text('2 action(s) synchronisee(s).'), findsOneWidget);
    });

    testWidgets('affiche un message si aucune action n est synchronisee', (
      WidgetTester tester,
    ) async {
      final repository = _RetryFakeAttendanceRepository(retryResult: 0);

      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            attendanceRepositoryProvider.overrideWith((ref) => repository),
            attendanceStatusProvider.overrideWith(
              (ref) async => const AttendanceStatus(
                isCheckedIn: false,
                lastActionAt: null,
              ),
            ),
            attendanceHistoryProvider.overrideWith((ref) async {
              return <AttendanceRecord>[
                AttendanceRecord(
                  id: 'record-1',
                  actionType: AttendanceActionType.checkIn,
                  timestamp: DateTime(2026, 3, 2, 8, 0),
                  siteLabel: 'Siege Ouaga',
                ),
              ];
            }),
            attendancePendingSyncCountProvider.overrideWith((ref) async => 1),
          ],
          child: const MaterialApp(home: AttendancePage()),
        ),
      );

      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Synchroniser'));
      await tester.tap(find.text('Synchroniser'));
      await tester.pumpAndSettle();

      expect(repository.retryCalls, 1);
      expect(find.text('Aucune action a synchroniser.'), findsOneWidget);
    });
  });
}

class _RetryFakeAttendanceRepository implements AttendanceRepository {
  _RetryFakeAttendanceRepository({required this.retryResult});

  final int retryResult;
  int retryCalls = 0;

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
    return retryResult;
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
    retryCalls++;
    return retryResult;
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
