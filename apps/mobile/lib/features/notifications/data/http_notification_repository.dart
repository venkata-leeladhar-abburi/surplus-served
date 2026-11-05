import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../domain/app_notification.dart';
import '../domain/notification_repository.dart';

class HttpNotificationRepository implements NotificationRepository {
  HttpNotificationRepository({required this.authToken, http.Client? client})
      : _client = client ?? http.Client();

  final String? authToken;
  final http.Client _client;

  static const String _baseUrl = '${ApiConfig.apiUrl}/notifications';
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

  Map<String, dynamic> _decode(http.Response response) {
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
  Future<NotificationFeed> fetch() async {
    final response = await _client
        .get(Uri.parse(_baseUrl), headers: _headers)
        .timeout(_timeout);
    final json = _decode(response);

    final items = (json['notifications'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => AppNotification.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return NotificationFeed(
      items: items,
      unreadCount: (json['unreadCount'] as num?)?.toInt() ??
          items.where((n) => !n.read).length,
    );
  }

  @override
  Future<void> markRead(String id) async {
    final response = await _client
        .patch(Uri.parse('$_baseUrl/$id/read'), headers: _headers)
        .timeout(_timeout);
    _decode(response);
  }

  @override
  Future<void> markAllRead() async {
    final response = await _client
        .post(Uri.parse('$_baseUrl/read-all'), headers: _headers)
        .timeout(_timeout);
    _decode(response);
  }
}
