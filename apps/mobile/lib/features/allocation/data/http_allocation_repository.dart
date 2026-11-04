
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../donation/data/http_donation_repository.dart';
import '../../donation/domain/donation.dart';
import '../domain/allocation_repository.dart';

class HttpAllocationRepository implements AllocationRepository {
  HttpAllocationRepository({
    required this.authToken,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String? authToken;
  final http.Client _client;

  static const String _baseUrl =
      'https://surplus-served-backend.onrender.com/api/donations';

  Map<String, String> get _headers {
    if (authToken == null || authToken!.isEmpty) {
      throw Exception('Please log in to continue.');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $authToken',
    };
  }

  Future<void> _post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _client
        .post(
          Uri.parse('$_baseUrl$endpoint'),
          headers: _headers,
          body: jsonEncode(body ?? {}),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    String message = 'Request failed. Please try again.';

    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map) {
        message = decoded['message']?.toString() ?? message;
      }
    } catch (_) {
      // Keep the fallback error message.
    }

    throw Exception(message);
  }

  // Fetch allocations belonging to the logged-in donor.
  Future<List<Map<String, dynamic>>> getMyDonorAllocations() async {
    final response = await _client
        .get(
          Uri.parse('$_baseUrl/my-donor-allocations'),
          headers: _headers,
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Unable to fetch your allocations.';

      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map) {
          message = decoded['message']?.toString() ?? message;
        }
      } catch (_) {}

      throw Exception(message);
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map || decoded['allocations'] is! List) {
      throw Exception('Invalid allocations response from server.');
    }

    return (decoded['allocations'] as List)
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  @override
  Future<Donation> requestDonation({
    required String donationId,
    required String ngoId,
    required String ngoName,
    required int requestedPortions,
  }) async {
    if (requestedPortions < 1) {
      throw Exception('Please request at least one portion.');
    }

    await _post(
      '/$donationId/request',
      body: {
        'portions': requestedPortions,
      },
    );

    return HttpDonationRepository().getById(
      donationId,
      authToken: authToken,
    );
  }

  @override
  Future<void> confirmOffer({
    required String allocationId,
    required bool accept,
  }) async {
    await _post(
      '/allocations/$allocationId/confirm-offer',
      body: {
        'accept': accept,
      },
    );
  }

  @override
  Future<void> approveAllocation({
    required String allocationId,
  }) async {
    await _post('/allocations/$allocationId/approve');
  }

  @override
  Future<void> rejectAllocation({
    required String allocationId,
  }) async {
    await _post('/allocations/$allocationId/reject');
  }

  @override
  Future<void> verifyPickupCode({
    required String allocationId,
    required String code,
  }) async {
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      throw Exception('Enter a valid six-digit pickup code.');
    }

    await _post(
      '/allocations/$allocationId/verify-pickup',
      body: {
        'code': code,
      },
    );
  }

  @override
  Future<CodeEntryResult> enterPickupCode({
    required String donationId,
    required String code,
  }) async {
    throw UnsupportedError(
      'Pickup verification now requires an allocation ID '
      'and is performed by the donor.',
    );
  }
}
