import 'user_role.dart';

class Session {
  const Session({
    required this.userId,
    required this.name,
    required this.phone,
    required this.role,
  });

  final String userId;
  final String name;
  final String phone;
  final UserRole role;
}
