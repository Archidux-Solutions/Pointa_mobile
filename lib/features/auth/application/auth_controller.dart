import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointa_mobile/features/auth/application/auth_state.dart';
import 'package:pointa_mobile/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:pointa_mobile/features/auth/domain/exceptions/auth_exception.dart';

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

  Future<void> signOut() async {
    final repository = ref.read(authRepositoryProvider);
    await repository.signOut();
    state = AuthState.initial();
  }
}
