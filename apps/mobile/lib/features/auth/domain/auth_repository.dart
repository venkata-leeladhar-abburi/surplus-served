import 'session.dart';
import 'user_role.dart';

abstract class AuthRepository {
  /// Sends an OTP via MSG91 in production; the fixture accepts any 10-digit
  /// number and any 4-digit code.
  Future<void> sendOtp(String phone);

  Future<Session> verifyOtp({required String phone, required String otp, required UserRole role});
}
