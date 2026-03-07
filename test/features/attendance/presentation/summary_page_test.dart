import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointa_mobile/features/attendance/application/attendance_providers.dart';
import 'package:pointa_mobile/features/attendance/domain/models/attendance_record.dart';
import 'package:pointa_mobile/features/attendance/presentation/pages/summary_page.dart';

void main() {
  group('SummaryPage', () {
    testWidgets('affiche le recap hebdomadaire et les groupes de jours', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            attendanceHistoryProvider.overrideWith((ref) async {
              return <AttendanceRecord>[
                AttendanceRecord(
                  id: 'record-1',
                  actionType: AttendanceActionType.checkIn,
                  timestamp: DateTime(2024, 4, 21, 8, 6),
                  siteLabel: 'Siege Ouaga',
                ),
                AttendanceRecord(
                  id: 'record-2',
                  actionType: AttendanceActionType.checkOut,
                  timestamp: DateTime(2024, 4, 20, 18, 7),
                  siteLabel: 'Siege Ouaga',
                ),
                AttendanceRecord(
                  id: 'record-3',
                  actionType: AttendanceActionType.checkIn,
                  timestamp: DateTime(2024, 4, 20, 8, 14),
                  siteLabel: 'Siege Ouaga',
                ),
                AttendanceRecord(
                  id: 'record-4',
                  actionType: AttendanceActionType.checkOut,
                  timestamp: DateTime(2024, 4, 19, 17, 0),
                  siteLabel: 'Siege Ouaga',
                ),
                AttendanceRecord(
                  id: 'record-5',
                  actionType: AttendanceActionType.checkIn,
                  timestamp: DateTime(2024, 4, 19, 8, 8),
                  siteLabel: 'Siege Ouaga',
                ),
              ];
            }),
          ],
          child: const MaterialApp(home: SummaryPage()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Recap heures & retards'), findsOneWidget);
      expect(find.text('Recap de la semaine'), findsOneWidget);
      expect(find.text('Du 15 avril 2024 au 21 avril 2024'), findsOneWidget);
      expect(find.text('Dimanche 21 avril'), findsOneWidget);
      expect(find.text('Samedi 20 avril'), findsOneWidget);
      expect(find.text('Vendredi 19 avril'), findsOneWidget);
      expect(find.text('Temps travaille'), findsOneWidget);
      expect(find.text('Retards'), findsAtLeastNWidgets(1));
      expect(find.text('Absences'), findsOneWidget);
    });

    testWidgets('affiche un etat vide quand aucun pointage n est disponible', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            attendanceHistoryProvider.overrideWith(
              (ref) async => <AttendanceRecord>[],
            ),
          ],
          child: const MaterialApp(home: SummaryPage()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Aucune donnee sur cette periode'), findsOneWidget);
      expect(
        find.text('Choisissez une autre plage pour afficher le recap.'),
        findsOneWidget,
      );
    });

    testWidgets('affiche erreur et relance le provider avec Reessayer', (
      WidgetTester tester,
    ) async {
      var calls = 0;

      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            attendanceHistoryProvider.overrideWith((ref) async {
              calls++;
              throw Exception('erreur reseau');
            }),
          ],
          child: const MaterialApp(home: SummaryPage()),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Recap indisponible'), findsOneWidget);
      final callsBeforeRetry = calls;

      await tester.tap(find.byKey(const Key('summary_retry_button')));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Recap indisponible'), findsOneWidget);
      expect(calls, greaterThan(callsBeforeRetry));
    });
  });
}
