import 'package:pointa_mobile/features/auth/domain/models/user_session.dart';

enum AuthStatus { unauthenticated, authenticated }

class AuthState {
  const AuthState({
    required this.status,
    this.session,
    this.isRestoring = false,
    this.isLocked = false,
    this.isLoading = false,
    this.errorMessage,
  });

  factory AuthState.initial() =>
      const AuthState(
        status: AuthStatus.unauthenticated,
        isRestoring: true,
      );

  final AuthStatus status;
  final UserSession? session;
  final bool isRestoring;
  final bool isLocked;
  final bool isLoading;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    UserSession? session,
    bool resetSession = false,
    bool? isRestoring,
    bool? isLocked,
    bool? isLoading,
    String? errorMessage,
    bool resetError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      session: resetSession ? null : (session ?? this.session),
      isRestoring: isRestoring ?? this.isRestoring,
      isLocked: isLocked ?? this.isLocked,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: resetError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
