
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/donation.dart';
import '../domain/donation_status.dart';
import '../domain/donation_repository.dart';

class HttpDonationRepository implements DonationRepository {
  HttpDonationRepository({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  static const String _baseUrl =
      'https://surplus-served-backend.onrender.com/api/donations';

  Map<String, String> _headers(String? authToken) {
    return {
      'Content-Type': 'application/json',
      if (authToken != null && authToken.isNotEmpty)
        'Authorization': 'Bearer $authToken',
    };
  }

  // Convert backend statuses into frontend domain statuses.
  DonationStatus _mapStatus(dynamic status) {
    switch (status?.toString().toLowerCase()) {
      case 'available':
        return DonationStatus.live;

      case 'claimed':
        return DonationStatus.allocated;

      case 'collected':
        return DonationStatus.collected;

      case 'cancelled':
        return DonationStatus.cancelled;

      // Support frontend statuses if the API returns them.
      case 'draft':
        return DonationStatus.draft;

      case 'pendingcheck':
        return DonationStatus.pendingCheck;

      case 'live':
        return DonationStatus.live;

      case 'allocated':
        return DonationStatus.allocated;

      case 'reallocated':
        return DonationStatus.reallocated;

      case 'unfulfilled':
        return DonationStatus.unfulfilled;

      case 'rejected':
        return DonationStatus.rejected;

      default:
        throw FormatException(
          'Unknown donation status received from server: $status',
        );
    }
  }

  // Fetch donations created by the logged-in donor.
  @override
  Stream<List<Donation>> watchDonorDonations(
    String donorId, {
    String? authToken,
  }) async* {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/mine'),
        headers: _headers(authToken),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        final List<dynamic> jsonList;

        if (decoded is List) {
          jsonList = decoded;
        } else if (decoded is Map<String, dynamic> &&
            decoded['donations'] is List) {
          jsonList = decoded['donations'] as List<dynamic>;
        } else {
          throw Exception('Unexpected donations response from server.');
        }

        final donations = jsonList
            .map(
              (json) => _fromJson(
                Map<String, dynamic>.from(json as Map),
              ),
            )
            .toList();

        donations.sort(
          (a, b) => b.createdAt.compareTo(a.createdAt),
        );

        yield donations;
      } else {
        throw Exception(
          _getErrorMessage(response, 'Failed to load donor donations'),
        );
      }
    } catch (e) {
      throw Exception(
        'Network error loading history: '
        '${e.toString().replaceAll('Exception: ', '')}',
      );
    }
  }

  // Fetch one donation by ID.
  @override
  Future<Donation> getById(
    String id, {
    String? authToken,
  }) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/$id'),
        headers: _headers(authToken),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        final donationData = decoded is Map &&
                decoded['donation'] is Map
            ? decoded['donation']
            : decoded;

        return _fromJson(
          Map<String, dynamic>.from(donationData as Map),
        );
      }

      throw Exception(
        _getErrorMessage(response, 'Failed to fetch donation details'),
      );
    } catch (e) {
      throw Exception(
        'Network error: ${e.toString().replaceAll('Exception: ', '')}',
      );
    }
  }

  // Create a donation.
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
        headers: _headers(authToken),
        body: jsonEncode({
          'donorId': donorId,
          'donorName': donorName,
          'title': title,
          'description': description,
          'portions': portions,
          'pickupWindowStart': pickupWindowStart.toUtc().toIso8601String(),
          'pickupWindowEnd': pickupWindowEnd.toUtc().toIso8601String(),
          'address': {
            'locality': address.locality,
          },
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        final donationData = decoded is Map &&
                decoded['donation'] is Map
            ? decoded['donation']
            : decoded;

        return _fromJson(
          Map<String, dynamic>.from(donationData as Map),
        );
      }

      throw Exception(
        _getErrorMessage(response, 'Failed to create donation'),
      );
    } catch (e) {
      throw Exception(
        'Failed to create donation: '
        '${e.toString().replaceAll('Exception: ', '')}',
      );
    }
  }

  // Cancel a donation.
  @override
  Future<void> cancel(
    String id, {
    String? authToken,
  }) async {
    try {
      final response = await _client.patch(
        Uri.parse('$_baseUrl/$id/cancel'),
        headers: _headers(authToken),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception(
          _getErrorMessage(response, 'Failed to cancel donation'),
        );
      }
    } catch (e) {
      throw Exception(
        'Network error cancelling donation: '
        '${e.toString().replaceAll('Exception: ', '')}',
      );
    }
  }

  String _getErrorMessage(
    http.Response response,
    String fallbackMessage,
  ) {
    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded['message']?.toString() ?? fallbackMessage;
      }
    } catch (_) {
      // Use fallback message when the response is not valid JSON.
    }

    return '$fallbackMessage (${response.statusCode})';
  }

  Donation _fromJson(Map<String, dynamic> json) {
    final addressJson = json['address'] is Map
        ? Map<String, dynamic>.from(json['address'])
        : <String, dynamic>{};

    return Donation(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      donorId: json['donorId']?.toString() ?? '',
      donorName: json['donorName']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      portions: (json['portions'] as num?)?.toInt() ?? 0,
      remainingPortions: (json['remainingPortions'] as num?)?.toInt(),
      status: _mapStatus(json['status']),
      pickupWindowStart: json['pickupWindowStart'] != null
          ? DateTime.parse(json['pickupWindowStart'].toString())
          : DateTime.now(),
      pickupWindowEnd: json['pickupWindowEnd'] != null
          ? DateTime.parse(json['pickupWindowEnd'].toString())
          : DateTime.now().add(const Duration(hours: 2)),
      address: PickupAddress(
        locality: addressJson['locality']?.toString() ?? '',
        exactLine: addressJson['exactLine']?.toString(),
        contactName: addressJson['contactName']?.toString(),
        contactPhone: addressJson['contactPhone']?.toString(),
        latitude: (addressJson['latitude'] as num?)?.toDouble(),
        longitude: (addressJson['longitude'] as num?)?.toDouble(),
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      allocatedToNgoId: json['allocatedToNgoId']?.toString(),
      allocatedToNgoName: json['allocatedToNgoName']?.toString(),
      pickupCode: json['pickupCode']?.toString(),
    );
  }
}
