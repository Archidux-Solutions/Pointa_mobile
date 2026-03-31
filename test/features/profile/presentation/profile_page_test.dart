import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointa_mobile/features/auth/application/auth_controller.dart';
import 'package:pointa_mobile/features/auth/application/auth_state.dart';
import 'package:pointa_mobile/features/auth/domain/models/user_session.dart';
import 'package:pointa_mobile/features/profile/presentation/pages/profile_page.dart';

void main() {
  group('ProfilePage', () {
    testWidgets('affiche les informations principales du compte', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(_ProfileFakeAuthController.new),
          ],
          child: const MaterialApp(home: ProfilePage()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Profil'), findsWidgets);
      expect(find.text('Abdoul Latif Sinon'), findsWidgets);
      expect(find.text('abdoul@pointa.app'), findsWidgets);
      expect(find.byKey(const Key('profile_edit_button')), findsOneWidget);
    });

    testWidgets('permet d editer localement le profil depuis la feuille', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(_ProfileFakeAuthController.new),
          ],
          child: const MaterialApp(home: ProfilePage()),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('profile_edit_button')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'Awa Ouedraogo');
      await tester.enterText(find.byType(TextField).at(1), 'awa@pointa.app');
      await tester.enterText(find.byType(TextField).at(2), '+226 70 55 66 77');
      await tester.tap(find.byKey(const Key('profile_save_button')));
      await tester.pumpAndSettle();

      expect(find.text('Awa Ouedraogo'), findsWidgets);
      expect(find.text('awa@pointa.app'), findsWidgets);
      expect(find.text('+226 70 55 66 77'), findsOneWidget);
    });
  });
}

class _ProfileFakeAuthController extends AuthController {
  @override
  AuthState build() {
    return const AuthState(
      status: AuthStatus.authenticated,
      session: UserSession(
        userId: 'mock-user-001',
        displayName: 'Abdoul Latif Sinon',
        email: 'abdoul@pointa.app',
        phoneNumber: '+226 70 12 34 56',
      ),
    );
  }

  @override
  Future<void> updateProfile({
    required String displayName,
    required String email,
    required String phoneNumber,
  }) async {
    state = state.copyWith(
      session: UserSession(
        userId: state.session!.userId,
        displayName: displayName,
        email: email,
        phoneNumber: phoneNumber,
      ),
    );
  }
}
