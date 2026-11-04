
import 'session.dart';
import 'user_role.dart';

abstract class AuthRepository {
  Future<Session> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? organizationName,
    String? registrationNumber,
    String? certificatePath,
  });

  Future<Session> login({
    required String email,
    required String password,
  });
}
