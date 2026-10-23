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
  Future<void> sendOtp(String phone) async {
    // If using phone/OTP or request endpoint on your backend
    final response = await _client.post(
      Uri.parse('$_baseUrl/send-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send OTP');
    }
  }

  @override
  Future<Session> verifyOtp({
    required String phone,
    required String otp,
    required UserRole role,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/verify-otp'), // Or /login /register route
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': phone,
        'otp': otp,
        'role': role.name,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);

      // Extract the real user _id, token, and name returned from backend
      final user = data['user'];
      final token = data['token'];

      return Session(
        userId: user['_id'] ?? user['id'], // Real 24-character MongoDB ObjectId
        name: user['name'] ?? 'User',
        phone: user['phone'] ?? phone,
        role: role,
        token: token, // Real JWT token
      );
    } else {
      throw Exception('Authentication failed: ${response.body}');
    }
  }
}
