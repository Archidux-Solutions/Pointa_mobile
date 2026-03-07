import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'mockup_screens.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final screens = <String, Widget>{
    '01_login': const PreviewFrame(child: LoginPreview()),
    '02_dashboard': const PreviewFrame(child: DashboardPreview()),
    '03_pointage': const PreviewFrame(child: PointagePreview()),
    '04_historique': const PreviewFrame(child: HistoryPreview()),
    '05_recap': const PreviewFrame(child: RecapPreview()),
    '06_profil': const PreviewFrame(child: ProfilePreview()),
  };

  for (final entry in screens.entries) {
    testWidgets('genere ${entry.key}', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(entry.value);
      await tester.pump();

      await expectLater(
        find.byKey(const Key('preview-root')),
        matchesGoldenFile('goldens/${entry.key}.png'),
      );
    });
  }
}
