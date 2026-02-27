import 'package:pointa_mobile/features/auth/domain/models/user_session.dart';

abstract class AuthRepository {
  Future<UserSession> signInWithEmail({
    required String email,
    required String password,
  });

  Future<void> signOut();
}
