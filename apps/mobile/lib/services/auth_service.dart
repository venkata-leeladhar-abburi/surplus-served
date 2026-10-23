import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Replace this with your live deployed backend URL once ready
  static const String baseUrl = 'https://surplus-served-backend.onrender.com';

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
    Map<String, dynamic>? ngoDetails,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        if (ngoDetails != null) 'ngoDetails': ngoDetails,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Registration failed');
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Login failed');
    }
  }
}
