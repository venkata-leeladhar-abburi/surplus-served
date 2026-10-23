import 'dart:convert';
import 'package:http/http.dart' as http;

import '../domain/donation.dart';
import '../domain/donation_status.dart';
import '../domain/donation_repository.dart';

class HttpDonationRepository implements DonationRepository {
  HttpDonationRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const String _baseUrl = 'https://surplus-served-backend.onrender.com/api/donations';

  @override
  Stream<List<Donation>> watchDonorDonations(String donorId, {String? authToken}) async* {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl?donorId=$donorId'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final donations = jsonList.map((json) => _fromJson(json)).toList();
        donations.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        yield donations;
      } else {
        throw Exception('Failed to load donor donations from server (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Network error loading history: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  @override
  Future<Donation> getById(String id, {String? authToken}) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        return _fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch donation details (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  @override
  Future<Donation> create({
    required String donorId,
    required String donorName,
    required String title,
    String? description,
    required int portions,
    required DateTime pickupWindowStart,
    required DateTime pickupWindowEnd,
    required PickupAddress address,
    String? authToken,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'donorId': donorId,
          'donorName': donorName,
          'title': title,
          'description': description,
          'portions': portions,
          'pickupWindowStart': pickupWindowStart.toIso8601String(),
          'pickupWindowEnd': pickupWindowEnd.toIso8601String(),
          'address': {
            'locality': address.locality
            
          },
        }),
      ).timeout(const Duration(seconds: 30)); // Extended timeout for Render spin-up delays

      if (response.statusCode == 201 || response.statusCode == 200) {
        return _fromJson(jsonDecode(response.body));
      } else {
        String errorMessage = 'Failed to create donation';
        try {
          final errorBody = jsonDecode(response.body);
          if (errorBody is Map && errorBody.containsKey('message')) {
            errorMessage = errorBody['message'];
          }
        } catch (_) {
          errorMessage = 'Server error (${response.statusCode})';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Failed to create donation: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  @override
  Future<void> cancel(String id, {String? authToken}) async {
    try {
      final response = await _client.patch(
        Uri.parse('$_baseUrl/$id/cancel'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception('Failed to cancel donation (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Network error cancelling donation: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  Donation _fromJson(Map<String, dynamic> json) {
    final statusStr = json['status']?.toString().toLowerCase();
    return Donation(
      id: json['_id'] ?? json['id'] ?? '',
      donorId: json['donorId'] ?? '',
      donorName: json['donorName'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      portions: json['portions'] ?? 0,
      status: DonationStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == statusStr,
        orElse: () => DonationStatus.values.first,
      ),
      pickupWindowStart: json['pickupWindowStart'] != null
          ? DateTime.parse(json['pickupWindowStart'])
          : DateTime.now(),
      pickupWindowEnd: json['pickupWindowEnd'] != null
          ? DateTime.parse(json['pickupWindowEnd'])
          : DateTime.now().add(const Duration(hours: 2)),
      address: PickupAddress(
        locality: json['address']?['locality'] ?? '',
        exactLine: json['address']?['exactLine'],
        contactName: json['address']?['contactName'],
        contactPhone: json['address']?['contactPhone'],
        latitude: json['address']?['latitude']?.toDouble(),
        longitude: json['address']?['longitude']?.toDouble(),
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      allocatedToNgoId: json['allocatedToNgoId'],
      allocatedToNgoName: json['allocatedToNgoName'],
      pickupCode: json['pickupCode'],
    );
  }
}
