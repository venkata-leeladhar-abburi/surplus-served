import '../domain/auth_repository.dart';
import '../domain/session.dart';
import '../domain/user_role.dart';

class AuthRepositoryFixture implements AuthRepository {
  @override
  Future<Session> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    return Session(
      userId: 'mock_user_123',
      name: name,
      phone: '',
      role: role,
      token: 'mock_jwt_token',
    );
  }

  @override
  Future<Session> login({
    required String email,
    required String password,
  }) async {
    return const Session(
      userId: 'mock_user_123',
      name: 'Mock User',
      phone: '',
      role: UserRole.donor,
      token: 'mock_jwt_token',
    );
  }
}
