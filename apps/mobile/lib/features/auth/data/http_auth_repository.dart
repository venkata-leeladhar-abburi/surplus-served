
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../domain/auth_repository.dart';
import '../domain/session.dart';
import '../domain/user_role.dart';

class HttpAuthRepository implements AuthRepository {
  HttpAuthRepository({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  static const String _baseUrl =
      'https://surplus-served-backend.onrender.com/api/auth';

  @override
  Future<Session> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? organizationName,
    String? registrationNumber,
    String? certificatePath,
  }) async {
    if (role == UserRole.admin) {
      throw Exception('Admin registration is not allowed.');
    }

    late http.Response response;

    if (role == UserRole.ngo) {
      if (organizationName == null ||
          organizationName.trim().isEmpty ||
          registrationNumber == null ||
          registrationNumber.trim().isEmpty ||
          certificatePath == null ||
          certificatePath.trim().isEmpty) {
        throw Exception(
          'NGO organization details and certificate are required.',
        );
      }

      final file = File(certificatePath);

      if (!await file.exists()) {
        throw Exception('Selected certificate file does not exist.');
      }

      final extension =
          certificatePath.split('.').last.toLowerCase();

      final MediaType contentType;

      switch (extension) {
        case 'jpg':
        case 'jpeg':
          contentType = MediaType('image', 'jpeg');
          break;

        case 'png':
          contentType = MediaType('image', 'png');
          break;

        case 'pdf':
          contentType = MediaType('application', 'pdf');
          break;

        default:
          throw Exception(
            'Only JPG, PNG and PDF certificates are allowed.',
          );
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/register'),
      );

      request.fields.addAll({
        'name': name,
        'email': email,
        'password': password,
        'role': role.name,
        'organizationName': organizationName,
        'registrationNumber': registrationNumber,
      });

      request.files.add(
        await http.MultipartFile.fromPath(
          'certificate',
          certificatePath,
          contentType: contentType,
        ),
      );

      final streamedResponse = await _client.send(request);
      response = await http.Response.fromStream(streamedResponse);
    } else {
      response = await _client.post(
        Uri.parse('$_baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role.name,
        }),
      );
    }

    if (response.statusCode == 201) {
      final data = _decodeResponse(response);

      return _createSession(data, fallbackName: name);
    }

    throw Exception(_getErrorMessage(response, 'Registration failed'));
  }

  @override
  Future<Session> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = _decodeResponse(response);

      return _createSession(data, fallbackName: 'User');
    }

    throw Exception(_getErrorMessage(response, 'Login failed'));
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      throw Exception('Unexpected server response.');
    } catch (e) {
      throw Exception('Unable to read server response.');
    }
  }

  Session _createSession(
    Map<String, dynamic> data, {
    required String fallbackName,
  }) {
    final roleString = data['role']?.toString().toLowerCase();

    final userRole = UserRole.values.firstWhere(
      (role) => role.name == roleString,
      orElse: () => throw Exception('Unsupported user role: $roleString'),
    );

    final token = data['token']?.toString();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token was not received.');
    }

    return Session(
      userId: data['_id']?.toString() ?? '',
      name: data['name']?.toString() ?? fallbackName,
      phone: '',
      role: userRole,
      token: token,
    );
  }

  String _getErrorMessage(
    http.Response response,
    String fallbackMessage,
  ) {
    try {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic>) {
        return data['message']?.toString() ?? fallbackMessage;
      }
    } catch (_) {
      // Use the fallback message if the response is not valid JSON.
    }

    return fallbackMessage;
  }
}
