import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointa_mobile/core/network/pointa_api_client_provider.dart';
import 'package:pointa_mobile/features/attendance/application/attendance_providers.dart';
import 'package:pointa_mobile/features/auth/application/device_unlock_service.dart';
import 'package:pointa_mobile/features/auth/application/auth_state.dart';
import 'package:pointa_mobile/features/auth/data/session/persisted_auth_session_store.dart';
import 'package:pointa_mobile/features/auth/data/repositories/auth_repository_provider.dart';
import 'package:pointa_mobile/features/auth/domain/exceptions/auth_exception.dart';
import 'package:pointa_mobile/features/auth/domain/models/password_reset_challenge.dart';
import 'package:pointa_mobile/features/auth/domain/models/user_session.dart';

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthState> {
  bool _didStartRestore = false;

  @override
  AuthState build() {
    if (!_didStartRestore) {
      _didStartRestore = true;
      Future<void>.microtask(_restorePersistedSession);
    }
    return AuthState.initial();
  }

  Future<void> signIn({required String phone, required String password}) async {
    final repository = ref.read(authRepositoryProvider);
    state = state.copyWith(isLoading: true, resetError: true);
    _resetSessionScopedState();

    try {
      final session = await repository.signIn(phone: phone, password: password);
      await _persistCurrentSession(session);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        session: session,
        isRestoring: false,
        isLocked: false,
        isLoading: false,
      );
    } on AuthException catch (error) {
      await _clearPersistedSession();
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isRestoring: false,
        isLocked: false,
        isLoading: false,
        resetSession: true,
        errorMessage: error.message,
      );
    } catch (_) {
      await _clearPersistedSession();
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isRestoring: false,
        isLocked: false,
        isLoading: false,
        resetSession: true,
        errorMessage: 'Connexion backend impossible. Reessayez.',
      );
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final repository = ref.read(authRepositoryProvider);

    try {
      await repository.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      state = state.copyWith(resetError: true);
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException('Modification impossible. Reessayez.');
    }
  }

  Future<PasswordResetChallenge> requestPasswordReset({
    required String phone,
    String channel = 'auto',
  }) async {
    final repository = ref.read(authRepositoryProvider);

    try {
      return await repository.requestPasswordReset(
        phone: phone,
        channel: channel,
      );
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException('Reinitialisation impossible. Reessayez.');
    }
  }

  Future<void> resetPassword({
    required String requestId,
    required String verificationCode,
    required String newPassword,
  }) async {
    final repository = ref.read(authRepositoryProvider);

    try {
      await repository.resetPassword(
        requestId: requestId,
        verificationCode: verificationCode,
        newPassword: newPassword,
      );
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException('Reinitialisation impossible. Reessayez.');
    }
  }

  Future<void> deleteAccount({required String currentPassword}) async {
    final repository = ref.read(authRepositoryProvider);

    try {
      await repository.deleteAccount(currentPassword: currentPassword);
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException('Suppression du compte impossible. Reessayez.');
    }

    await _clearPersistedSession();
    state = AuthState.initial().copyWith(
      isRestoring: false,
      isLocked: false,
      errorMessage: 'Compte supprime. Reconnectez-vous si necessaire.',
    );
  }

  Future<void> signOut() async {
    final repository = ref.read(authRepositoryProvider);
    try {
      await repository.signOut();
    } finally {
      await _clearPersistedSession();
      state = AuthState.initial().copyWith(isRestoring: false, isLocked: false);
    }
  }

  Future<void> updateProfile({
    required String displayName,
    required String email,
    required String phoneNumber,
  }) async {
    final session = state.session;
    if (session == null) {
      return;
    }

    final repository = ref.read(authRepositoryProvider);

    try {
      final updatedSession = await repository.updateProfile(
        fullName: displayName,
        email: email,
        phone: phoneNumber,
      );
      await _persistCurrentSession(updatedSession);
      state = state.copyWith(session: updatedSession, resetError: true);
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException('Mise a jour du profil impossible. Reessayez.');
    }
  }

  void lockApp() {
    if (state.status != AuthStatus.authenticated ||
        state.session == null ||
        state.isLocked) {
      return;
    }

    state = state.copyWith(isLocked: true, resetError: true);
  }

  Future<void> unlockWithDeviceSecurity() async {
    if (state.status != AuthStatus.authenticated || state.session == null) {
      return;
    }

    final deviceUnlockService = ref.read(deviceUnlockServiceProvider);
    final canUseDeviceSecurity =
        await deviceUnlockService.isDeviceSecurityAvailable();

    if (!canUseDeviceSecurity) {
      await requireFreshLogin(
        message:
            'Aucun verrouillage appareil actif. Reconnectez-vous pour acceder a Pointa.',
      );
      return;
    }

    state = state.copyWith(isLoading: true, resetError: true);
    final unlocked = await deviceUnlockService.requestUnlock();

    if (unlocked) {
      state = state.copyWith(isLocked: false, isLoading: false, resetError: true);
      return;
    }

    state = state.copyWith(
      isLoading: false,
      errorMessage: 'Deverrouillage annule ou refuse.',
    );
  }

  Future<void> requireFreshLogin({String? message}) async {
    await _clearPersistedSession();
    state = AuthState.initial().copyWith(
      isRestoring: false,
      isLocked: false,
      errorMessage: message,
    );
  }

  void clearError() {
    state = state.copyWith(resetError: true);
  }

  Future<void> _restorePersistedSession() async {
    try {
      final persistedStore = ref.read(persistedAuthSessionStoreProvider);
      final persistedSession = await persistedStore.read();

      if (persistedSession == null) {
        state = state.copyWith(isRestoring: false, isLocked: false);
        return;
      }

      final apiSessionStore = ref.read(apiSessionStoreProvider);
      apiSessionStore.update(
        accessToken: persistedSession.accessToken,
        refreshToken: persistedSession.refreshToken,
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        session: persistedSession.session,
        isRestoring: false,
        isLocked: true,
        isLoading: false,
        resetError: true,
      );
    } catch (_) {
      await _clearPersistedSession();
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isRestoring: false,
        isLocked: false,
        isLoading: false,
        resetSession: true,
      );
    }
  }

  Future<void> _persistCurrentSession(UserSession session) async {
    final apiSessionStore = ref.read(apiSessionStoreProvider);
    final accessToken = apiSessionStore.accessToken;
    final refreshToken = apiSessionStore.refreshToken;

    if (accessToken == null ||
        accessToken.isEmpty ||
        refreshToken == null ||
        refreshToken.isEmpty) {
      return;
    }

    try {
      await ref.read(persistedAuthSessionStoreProvider).save(
        session: session,
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    } catch (_) {
      // Keep authentication usable even if secure local persistence is unavailable.
    }
  }

  Future<void> _clearPersistedSession() async {
    ref.read(apiSessionStoreProvider).clear();
    try {
      await ref.read(persistedAuthSessionStoreProvider).clear();
    } catch (_) {
      // Ignore local storage cleanup failures to preserve sign-out resilience.
    }
    _resetSessionScopedState();
  }

  void _resetSessionScopedState() {
    ref.read(attendanceLocalDataSourceProvider).clear();
    ref.read(attendanceSyncQueueDataSourceProvider).clear();
    ref.invalidate(attendanceRepositoryProvider);
    ref.invalidate(attendanceStatusProvider);
    ref.invalidate(attendanceHistoryProvider);
    ref.invalidate(attendanceSummaryProvider);
    ref.invalidate(attendancePendingSyncCountProvider);
  }
}
