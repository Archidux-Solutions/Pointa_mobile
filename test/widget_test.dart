import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';
import 'package:pointa_mobile/app/pointa_app.dart';
import 'package:pointa_mobile/features/auth/data/repositories/auth_repository_provider.dart';
import 'package:pointa_mobile/features/auth/data/repositories/mock_auth_repository.dart';

ProviderScope _appWithMockAuth() {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(const MockAuthRepository()),
    ],
    child: const PointaApp(),
  );
}

void main() {
  testWidgets('Le flux mock de connexion redirige vers le tableau de bord', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_appWithMockAuth());

    expect(find.text('Connexion'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('login_phone_field')),
      '+22670000000',
    );
    await tester.enterText(
      find.byKey(const Key('login_password_field')),
      'secret123',
    );

    await tester.ensureVisible(find.byKey(const Key('login_submit_button')));
    await tester.tap(find.byKey(const Key('login_submit_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.text('Bonjour,'), findsOneWidget);
  });

  testWidgets('Le lien creation de compte ouvre l ecran inscription', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_appWithMockAuth());

    await tester.ensureVisible(find.byKey(const Key('login_to_register_link')));
    await tester.tap(find.byKey(const Key('login_to_register_link')));
    await tester.pumpAndSettle();

    expect(find.text('Creer un compte'), findsOneWidget);
    expect(find.byKey(const Key('register_full_name_field')), findsOneWidget);
  });

  testWidgets('Le flux mock inscription redirige vers le tableau de bord', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_appWithMockAuth());

    await tester.ensureVisible(find.byKey(const Key('login_to_register_link')));
    await tester.tap(find.byKey(const Key('login_to_register_link')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('register_full_name_field')),
      'Awa Ouedraogo',
    );
    await tester.enterText(
      find.byKey(const Key('register_phone_field')),
      '+22670000001',
    );
    await tester.enterText(
      find.byKey(const Key('register_email_field')),
      'awa@pointa.app',
    );
    await tester.enterText(
      find.byKey(const Key('register_password_field')),
      'secret123',
    );
    await tester.enterText(
      find.byKey(const Key('register_confirm_password_field')),
      'secret123',
    );

    await tester.tap(find.byKey(const Key('register_terms_checkbox')));
    await tester.ensureVisible(find.byKey(const Key('register_submit_button')));
    await tester.tap(find.byKey(const Key('register_submit_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.text('Bonjour,'), findsOneWidget);
  });

  testWidgets(
    'La navigation basse ouvre le profil puis permet la deconnexion',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_appWithMockAuth());

      await tester.enterText(
        find.byKey(const Key('login_phone_field')),
        '+22670000000',
      );
      await tester.enterText(
        find.byKey(const Key('login_password_field')),
        'secret123',
      );

      await tester.ensureVisible(find.byKey(const Key('login_submit_button')));
      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Profil'));
      await tester.tap(find.text('Profil').last);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('profile_edit_button')), findsOneWidget);
      expect(find.text('+22670000000'), findsWidgets);
      final signOutButton = tester.widget<OutlinedButton>(
        find.byKey(const Key('profile_sign_out_button')),
      );
      signOutButton.onPressed!.call();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      expect(find.text('Connexion'), findsOneWidget);
    },
  );
}
