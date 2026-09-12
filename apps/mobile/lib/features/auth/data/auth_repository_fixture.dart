import '../domain/auth_repository.dart';
import '../domain/session.dart';
import '../domain/user_role.dart';

class AuthRepositoryFixture implements AuthRepository {
  @override
  Future<void> sendOtp(String phone) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<Session> verifyOtp({
    required String phone,
    required String otp,
    required UserRole role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final id = role == UserRole.donor ? 'donor-demo' : 'ngo-demo';
    final name = role == UserRole.donor
        ? 'Green Leaf Caterers'
        : 'Anna Poorna Trust';
    return Session(userId: id, name: name, phone: phone, role: role);
  }
}
