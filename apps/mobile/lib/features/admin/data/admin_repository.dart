import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../domain/admin_models.dart';

/// Talks to the admin-only endpoints under /api/admin.
/// Every call needs the admin's JWT; the backend rejects other roles (403).
class AdminRepository {
  AdminRepository({required this.authToken, http.Client? client})
      : _client = client ?? http.Client();

  final String? authToken;
  final http.Client _client;

  static const String _baseUrl = '${ApiConfig.apiUrl}/admin';
  static const Duration _timeout = Duration(seconds: 30);

  Map<String, String> get _headers {
    final token = authToken;

    if (token == null || token.isEmpty) {
      throw Exception('Please log in as admin to continue.');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');

    final http.Response response = switch (method) {
      'PATCH' => await _client
          .patch(uri, headers: _headers, body: jsonEncode(body ?? {}))
          .timeout(_timeout),
      _ => await _client.get(uri, headers: _headers).timeout(_timeout),
    };

    dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      throw Exception('Invalid response from server (${response.statusCode}).');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map ? decoded['message']?.toString() : null;
      throw Exception(message ?? 'Request failed (${response.statusCode}).');
    }

    if (decoded is! Map) {
      throw Exception('Unexpected response from server.');
    }

    return Map<String, dynamic>.from(decoded);
  }

  List<Map<String, dynamic>> _list(Map<String, dynamic> data, String key) {
    final items = data[key];

    if (items is! List) {
      throw Exception('Unexpected response from server.');
    }

    return items
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  /// [status]: pending, verified or rejected.
  Future<List<NgoApplication>> getNgos(String status) async {
    final data = await _send('GET', '/ngos?status=$status');
    return _list(data, 'ngos').map(NgoApplication.fromJson).toList();
  }

  Future<void> approveNgo(String ngoId) async {
    await _send('PATCH', '/ngos/$ngoId/approve');
  }

  Future<void> rejectNgo(String ngoId, String reason) async {
    await _send('PATCH', '/ngos/$ngoId/reject', body: {'reason': reason});
  }

  Future<AdminStats> getStats() async {
    return AdminStats.fromJson(await _send('GET', '/stats'));
  }

  Future<List<AdminActivity>> getActivity() async {
    final data = await _send('GET', '/activity');
    return _list(data, 'allocations').map(AdminActivity.fromJson).toList();
  }

  Future<List<AdminDonation>> getDonations() async {
    final data = await _send('GET', '/donations');
    return _list(data, 'donations').map(AdminDonation.fromJson).toList();
  }
}
