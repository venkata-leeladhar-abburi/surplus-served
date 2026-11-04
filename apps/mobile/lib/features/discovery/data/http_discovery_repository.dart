
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../donation/domain/donation.dart';
import '../../donation/domain/donation_status.dart';
import '../domain/discovery_repository.dart';

class HttpDiscoveryRepository implements DiscoveryRepository {
  HttpDiscoveryRepository({
    required this.authToken,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String? authToken;
  final http.Client _client;

  static const String _baseUrl =
      'https://surplus-served-backend.onrender.com/api/donations';

  Map<String, String> get _headers {
    final token = authToken;

    if (token == null || token.isEmpty) {
      throw Exception('Please log in to browse donations.');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Stream<List<Donation>> watchLiveFeed({String? excludeDonorId}) {
    return Stream.fromFuture(_fetchLiveDonations());
  }

  Future<List<Donation>> _fetchLiveDonations() async {
    try {
      final response = await _client.get(
        Uri.parse(_baseUrl),
        headers: _headers,
      );

      final data = _decodeResponse(response);

      if (response.statusCode != 200) {
        throw Exception(
          data['message']?.toString() ?? 'Unable to load donations.',
        );
      }

      final donationsJson = data['donations'];

      if (donationsJson is! List) {
        throw Exception('Invalid donations response from server.');
      }

      final donations = donationsJson
          .whereType<Map<String, dynamic>>()
          .map(_fromJson)
          .toList();

      donations.sort(
        (a, b) => a.pickupWindowEnd.compareTo(b.pickupWindowEnd),
      );

      return donations;
    } catch (error) {
      if (error is Exception) rethrow;
      throw Exception('Unable to load donations. Please try again.');
    }
  }

  @override
  Future<Donation> getById(String id) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/$id'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        final data = _decodeResponse(response);
        throw Exception(
          data['message']?.toString() ??
              'Unable to load donation details.',
        );
      }

      final data = jsonDecode(response.body);

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid donation details response.');
      }

      return _fromJson(data['donation'] is Map<String, dynamic>
          ? data['donation'] as Map<String, dynamic>
          : data);
    } catch (error) {
      if (error is Exception) rethrow;
      throw Exception('Unable to load donation details.');
    }
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      throw Exception('Invalid server response.');
    } catch (_) {
      throw Exception('Unable to read server response.');
    }
  }

  Donation _fromJson(Map<String, dynamic> json) {
    final addressJson = json['address'];

    final address = addressJson is Map<String, dynamic>
        ? addressJson
        : <String, dynamic>{};

    return Donation(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      donorId: json['donorId']?.toString() ?? '',
      donorName: json['donorName']?.toString() ?? 'Donor',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      portions: _toInt(json['remainingPortions'] ?? json['portions']),
      status: _mapStatus(json['status']),
      pickupWindowStart: DateTime.parse(
        json['pickupWindowStart'].toString(),
      ),
      pickupWindowEnd: DateTime.parse(
        json['pickupWindowEnd'].toString(),
      ),
      address: PickupAddress(
        locality: address['locality']?.toString() ?? '',
      ),
      createdAt: DateTime.parse(
        json['createdAt']?.toString() ??
            json['pickupWindowStart'].toString(),
      ),
    );
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  DonationStatus _mapStatus(dynamic status) {
    switch (status?.toString().toLowerCase()) {
      case 'available':
      case 'live':
        return DonationStatus.live;
      case 'claimed':
      case 'allocated':
        return DonationStatus.allocated;
      case 'collected':
        return DonationStatus.collected;
      case 'cancelled':
        return DonationStatus.cancelled;
      default:
        throw FormatException(
          'Unknown donation status received from server: $status',
        );
    }
  }
}
