import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointa_mobile/features/auth/application/auth_state.dart';
import 'package:pointa_mobile/features/auth/data/repositories/auth_repository_provider.dart';
import 'package:pointa_mobile/features/auth/domain/exceptions/auth_exception.dart';
import 'package:pointa_mobile/features/auth/domain/models/user_session.dart';

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => AuthState.initial();

  Future<void> signIn({required String phone, required String password}) async {
    final repository = ref.read(authRepositoryProvider);
    state = state.copyWith(isLoading: true, resetError: true);

    try {
      final session = await repository.signIn(phone: phone, password: password);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        session: session,
        isLoading: false,
      );
    } on AuthException catch (error) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isLoading: false,
        resetSession: true,
        errorMessage: error.message,
      );
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isLoading: false,
        resetSession: true,
        errorMessage: 'Connexion backend impossible. Reessayez.',
      );
    }
  }

  Future<void> register({
    required String fullName,
    required String phone,
    required String email,
    required String password,
  }) async {
    final repository = ref.read(authRepositoryProvider);
    state = state.copyWith(isLoading: true, resetError: true);

    try {
      final session = await repository.register(
        fullName: fullName,
        phone: phone,
        email: email,
        password: password,
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        session: session,
        isLoading: false,
      );
    } on AuthException catch (error) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isLoading: false,
        resetSession: true,
        errorMessage: error.message,
      );
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isLoading: false,
        resetSession: true,
        errorMessage: 'Inscription backend impossible. Reessayez.',
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

  Future<void> signOut() async {
    final repository = ref.read(authRepositoryProvider);
    try {
      await repository.signOut();
    } finally {
      state = AuthState.initial();
    }
  }

  void updateProfile({
    required String displayName,
    required String email,
    required String phoneNumber,
  }) {
    final session = state.session;
    if (session == null) {
      return;
    }

    state = state.copyWith(
      session: UserSession(
        userId: session.userId,
        displayName: displayName.trim(),
        email: email.trim(),
        phoneNumber: phoneNumber.trim(),
      ),
    );
  }
}
