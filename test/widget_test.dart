import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pointa_mobile/app/pointa_app.dart';
import 'package:pointa_mobile/core/config/data_mode.dart';
import 'package:pointa_mobile/features/attendance/application/attendance_providers.dart';
import 'package:pointa_mobile/features/auth/application/device_unlock_service.dart';
import 'package:pointa_mobile/features/auth/data/session/persisted_auth_session_store.dart';
import 'package:pointa_mobile/features/auth/data/repositories/auth_repository_provider.dart';
import 'package:pointa_mobile/features/auth/data/repositories/mock_auth_repository.dart';

class _FakePersistedAuthSessionStore extends PersistedAuthSessionStore {
  _FakePersistedAuthSessionStore() : super(const FlutterSecureStorage());

  PersistedAuthSession? _session;

  @override
  Future<void> clear() async {
    _session = null;
  }

  @override
  Future<PersistedAuthSession?> read() async => _session;

  @override
  Future<void> save({
    required session,
    required String accessToken,
    required String refreshToken,
  }) async {
    _session = PersistedAuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      session: session,
    );
  }
}

class _FakeDeviceUnlockService extends DeviceUnlockService {
  _FakeDeviceUnlockService() : super(LocalAuthentication());

  @override
  Future<bool> isDeviceSecurityAvailable() async => true;

  @override
  Future<bool> requestUnlock() async => true;
}

ProviderScope _appWithMockAuth() {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(const MockAuthRepository()),
      dataModeProvider.overrideWithValue(DataMode.mock),
      persistedAuthSessionStoreProvider.overrideWithValue(
        _FakePersistedAuthSessionStore(),
      ),
      deviceUnlockServiceProvider.overrideWithValue(_FakeDeviceUnlockService()),
    ],
    child: const PointaApp(),
  );
}

void main() {
  testWidgets('Le flux mock de connexion redirige vers le tableau de bord', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(480, 932));
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

  testWidgets(
    'Le flux mot de passe oublie ouvre puis soumet la reinitialisation',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(480, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_appWithMockAuth());

      await tester.ensureVisible(find.byKey(const Key('login_forgot_password_button')));
      final forgotButton = tester.widget<TextButton>(
        find.byKey(const Key('login_forgot_password_button')),
      );
      forgotButton.onPressed!.call();
      await tester.pumpAndSettle();

      expect(find.text('Mot de passe oublie'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('forgot_phone_field')),
        '+22670000009',
      );
      await tester.tap(find.byKey(const Key('forgot_submit_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('forgot_new_password_field')),
        findsOneWidget,
      );

      await tester.enterText(
        find.byKey(const Key('forgot_new_password_field')),
        'secret456',
      );
      await tester.enterText(
        find.byKey(const Key('forgot_confirm_password_field')),
        'secret456',
      );
      await tester.tap(find.byKey(const Key('forgot_submit_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.text('Mot de passe oublie'), findsNothing);
    },
  );

  testWidgets(
    'La navigation basse ouvre le profil puis permet la deconnexion',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(480, 932));
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
