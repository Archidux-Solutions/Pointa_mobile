import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointa_mobile/features/attendance/application/attendance_providers.dart';
import 'package:pointa_mobile/features/attendance/domain/models/attendance_record.dart';
import 'package:pointa_mobile/features/attendance/presentation/pages/history_page.dart';

void main() {
  group('HistoryPage', () {
    testWidgets('affiche la plage de dates et les groupes d historique', (
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
              ];
            }),
          ],
          child: const MaterialApp(home: HistoryPage()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Du 20 avril 2024 au 21 avril 2024'), findsOneWidget);
      expect(find.text('Dimanche 21 avril'), findsOneWidget);
      expect(find.text('Samedi 20 avril'), findsOneWidget);
    });

    testWidgets('affiche un etat vide quand aucun historique', (
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
          child: const MaterialApp(home: HistoryPage()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Aucun pointage sur cette periode'), findsOneWidget);
      expect(
        find.text('Choisissez une autre plage pour afficher l historique.'),
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
          child: const MaterialApp(home: HistoryPage()),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Erreur de chargement'), findsOneWidget);
      final callsBeforeRetry = calls;

      await tester.tap(find.byKey(const Key('history_retry_button')));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Erreur de chargement'), findsOneWidget);
      expect(calls, greaterThan(callsBeforeRetry));
    });
  });
}
