import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';
import 'package:pointa_mobile/app/pointa_app.dart';

void main() {
  testWidgets('Le flux mock de connexion redirige vers le tableau de bord', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: PointaApp()));

    expect(find.text('Connexion a Pointa'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('login_email_field')),
      'test@pointa.app',
    );
    await tester.enterText(
      find.byKey(const Key('login_password_field')),
      'secret123',
    );

    await tester.tap(find.byKey(const Key('login_submit_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.text('Tableau de bord'), findsOneWidget);
  });
}
