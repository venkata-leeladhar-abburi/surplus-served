import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../domain/recurring_repository.dart';
import '../domain/recurring_template.dart';

class HttpRecurringRepository implements RecurringRepository {
  HttpRecurringRepository({required this.authToken, http.Client? client})
      : _client = client ?? http.Client();

  final String? authToken;
  final http.Client _client;

  static const String _baseUrl = '${ApiConfig.apiUrl}/recurring';
  static const Duration _timeout = Duration(seconds: 30);

  Map<String, String> get _headers {
    final token = authToken;
    if (token == null || token.isEmpty) {
      throw Exception('Please log in to continue.');
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
    final encoded = jsonEncode(body ?? {});

    final response = await switch (method) {
      'POST' => _client.post(uri, headers: _headers, body: encoded),
      'PATCH' => _client.patch(uri, headers: _headers, body: encoded),
      'DELETE' => _client.delete(uri, headers: _headers),
      _ => _client.get(uri, headers: _headers),
    }
        .timeout(_timeout);

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

    return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
  }

  @override
  Future<List<RecurringTemplate>> fetchTemplates() async {
    final json = await _send('GET', '');
    return (json['templates'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => RecurringTemplate.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<RecurringTemplate> createTemplate({
    required String title,
    required int portions,
    required int windowHours,
    required int safeHours,
    required String locality,
    required String foodCategory,
    String? dietType,
  }) async {
    final json = await _send('POST', '', body: {
      'title': title,
      'portions': portions,
      'windowHours': windowHours,
      'safeHours': safeHours,
      'locality': locality,
      'foodCategory': foodCategory,
      'dietType': ?dietType,
    });
    return RecurringTemplate.fromJson(
      Map<String, dynamic>.from(json['template'] as Map),
    );
  }

  @override
  Future<void> confirmToday(String templateId, {int? portions}) async {
    await _send('POST', '/$templateId/confirm', body: {
      'portions': ?portions,
    });
  }

  @override
  Future<void> skipToday(String templateId) async {
    await _send('POST', '/$templateId/skip');
  }

  @override
  Future<void> setActive(String templateId, bool active) async {
    await _send('PATCH', '/$templateId', body: {'active': active});
  }

  @override
  Future<void> deleteTemplate(String templateId) async {
    await _send('DELETE', '/$templateId');
  }
}
