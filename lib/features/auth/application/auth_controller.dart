import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointa_mobile/features/auth/application/auth_state.dart';
import 'package:pointa_mobile/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:pointa_mobile/features/auth/domain/exceptions/auth_exception.dart';
import 'package:pointa_mobile/features/auth/domain/models/user_session.dart';

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => AuthState.initial();

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final repository = ref.read(authRepositoryProvider);
    state = state.copyWith(isLoading: true, resetError: true);

    try {
      final session = await repository.signInWithEmail(
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
        errorMessage: 'Connexion impossible. Reessayez.',
      );
    }
  }

  Future<void> registerMockUser({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final repository = ref.read(authRepositoryProvider);
    state = state.copyWith(isLoading: true, resetError: true);

    try {
      final session = await repository.signInWithEmail(
        email: email,
        password: password,
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        session: UserSession(
          userId: session.userId,
          displayName: fullName.trim(),
          email: session.email,
          phoneNumber: session.phoneNumber,
        ),
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
        errorMessage: 'Inscription impossible. Reessayez.',
      );
    }
  }

  Future<void> signOut() async {
    final repository = ref.read(authRepositoryProvider);
    await repository.signOut();
    state = AuthState.initial();
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
