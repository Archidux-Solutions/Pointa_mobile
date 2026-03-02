import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointa_mobile/features/attendance/domain/models/attendance_record.dart';
import 'package:pointa_mobile/features/attendance/presentation/widgets/attendance_record_tile.dart';

void main() {
  group('AttendanceRecordTile', () {
    testWidgets('affiche le suffixe sync en attente quand isPendingSync=true', (
      WidgetTester tester,
    ) async {
      final record = AttendanceRecord(
        id: 'record-1',
        actionType: AttendanceActionType.checkIn,
        timestamp: DateTime(2026, 3, 2, 8, 15),
        siteLabel: 'Siege Ouaga',
        isPendingSync: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AttendanceRecordTile(record: record)),
        ),
      );

      expect(find.textContaining('Sync en attente'), findsOneWidget);
    });

    testWidgets('n affiche pas le suffixe quand isPendingSync=false', (
      WidgetTester tester,
    ) async {
      final record = AttendanceRecord(
        id: 'record-2',
        actionType: AttendanceActionType.checkOut,
        timestamp: DateTime(2026, 3, 2, 17, 10),
        siteLabel: 'Siege Ouaga',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AttendanceRecordTile(record: record)),
        ),
      );

      expect(find.textContaining('Sync en attente'), findsNothing);
    });
  });
}
