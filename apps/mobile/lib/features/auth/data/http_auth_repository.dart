import 'dart:convert';
import 'package:http/http.dart' as http;

import '../domain/auth_repository.dart';
import '../domain/session.dart';
import '../domain/user_role.dart';

class HttpAuthRepository implements AuthRepository {
  HttpAuthRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const String _baseUrl = 'https://surplus-served-backend.onrender.com/api/auth';

  @override
  Future<Session> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': role.name.toLowerCase(),
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);

      return Session(
        userId: data['_id'] ?? '',
        name: data['name'] ?? name,
        phone: '',
        role: role,
        token: data['token'],
      );
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Registration failed');
    }
  }

  @override
  Future<Session> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final roleStr = data['role']?.toString().toLowerCase() ?? 'donor';
      final userRole = UserRole.values.firstWhere(
        (e) => e.name.toLowerCase() == roleStr,
        orElse: () => UserRole.donor,
      );

      return Session(
        userId: data['_id'] ?? '',
        name: data['name'] ?? 'User',
        phone: '',
        role: userRole,
        token: data['token'],
      );
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Login failed');
    }
  }
}
