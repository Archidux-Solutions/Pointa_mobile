import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointa_mobile/features/attendance/application/attendance_providers.dart';
import 'package:pointa_mobile/features/attendance/domain/models/attendance_record.dart';
import 'package:pointa_mobile/features/attendance/presentation/pages/history_page.dart';

void main() {
  group('HistoryPage', () {
    testWidgets('affiche un etat vide quand aucun historique', (
      WidgetTester tester,
    ) async {
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

      expect(find.text('Aucune presence enregistree'), findsOneWidget);
      expect(
        find.text('Les actions de pointage apparaitront ici.'),
        findsOneWidget,
      );
    });

    testWidgets('affiche erreur et relance le provider avec Reessayer', (
      WidgetTester tester,
    ) async {
      var calls = 0;

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
