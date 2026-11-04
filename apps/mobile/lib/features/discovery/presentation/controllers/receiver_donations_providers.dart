
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../../core/providers.dart';
import '../../../allocation/domain/allocation.dart';
import '../../../donation/domain/donation.dart';
import '../../../donation/domain/donation_status.dart';

/// An NGO allocation together with its populated donation details.
class ReceiverAllocation {
  const ReceiverAllocation({
    required this.allocation,
    required this.donation,
  });

  final Allocation allocation;
  final Donation donation;
}

/// Fetches approved allocations belonging to the logged-in NGO.
///
/// Unlike the old provider, this preserves the allocation ID and pickup code.
final receiverAllocationsProvider =
    FutureProvider<List<ReceiverAllocation>>((ref) async {
  final session = ref.watch(sessionProvider);

  if (session == null || session.token == null || session.token!.isEmpty) {
    throw Exception('Please log in to view your requests.');
  }

  final allocations = await _fetchMyAllocations(session.token!);

  final results = <ReceiverAllocation>[];

  for (final item in allocations) {
    if (item['status']?.toString() != 'approved') continue;

    final donationData = item['donationId'];

    if (donationData is! Map) {
      throw Exception(
        'Donation details were not included in the allocation response.',
      );
    }

    final allocation = Allocation.fromJson(item);

    if (allocation.id.isEmpty || allocation.donationId.isEmpty) {
      throw Exception('Invalid allocation information received.');
    }

    final donation = _buildDonation(
      item,
      Map<String, dynamic>.from(donationData),
      session.userId,
    );

    results.add(
      ReceiverAllocation(
        allocation: allocation,
        donation: donation,
      ),
    );
  }

  results.sort(
    (a, b) => b.allocation.createdAt.compareTo(a.allocation.createdAt),
  );

  return results;
});

/// Compatibility provider for existing screens that still expect donations.
final receiverDonationsProvider = FutureProvider<List<Donation>>((ref) async {
  final allocations = await ref.watch(receiverAllocationsProvider.future);

  return allocations.map((item) => item.donation).toList();
});

Future<List<Map<String, dynamic>>> _fetchMyAllocations(
  String token,
) async {
  final response = await http.get(
    Uri.parse(
      'https://surplus-served-backend.onrender.com/api/donations/my-allocations',
    ),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  ).timeout(const Duration(seconds: 20));

  dynamic decoded;

  try {
    decoded = jsonDecode(response.body);
  } catch (_) {
    throw Exception('Invalid response received from server.');
  }

  if (response.statusCode != 200) {
    final message = decoded is Map
        ? decoded['message']?.toString()
        : null;

    throw Exception(message ?? 'Unable to load your requests.');
  }

  if (decoded is! Map || decoded['allocations'] is! List) {
    throw Exception('Invalid allocations response from server.');
  }

  return (decoded['allocations'] as List)
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

Donation _buildDonation(
  Map<String, dynamic> allocationData,
  Map<String, dynamic> donationData,
  String ngoId,
) {
  final addressData = donationData['address'];

  final address = addressData is Map
      ? Map<String, dynamic>.from(addressData)
      : <String, dynamic>{};

  final portions = _toInt(allocationData['allocatedPortions']);

  return Donation(
    id: donationData['_id']?.toString() ?? '',
    donorId: allocationData['donorId']?.toString() ?? '',
    donorName: donationData['donorName']?.toString() ?? 'Donor',
    title: donationData['title']?.toString() ?? 'Food donation',
    description: donationData['description']?.toString(),
    portions: portions,
    status: DonationStatus.allocated,
    pickupWindowStart: _toDate(donationData['pickupWindowStart']),
    pickupWindowEnd: _toDate(donationData['pickupWindowEnd']),
    address: PickupAddress(
      locality: address['locality']?.toString() ?? '',
      exactLine: address['exactLine']?.toString(),
      contactName: address['contactName']?.toString(),
      contactPhone: address['contactPhone']?.toString(),
      latitude: (address['latitude'] as num?)?.toDouble(),
      longitude: (address['longitude'] as num?)?.toDouble(),
    ),
    createdAt: _toDate(allocationData['createdAt']),
    allocatedToNgoId: ngoId,
    allocatedToNgoName: allocationData['ngoName']?.toString(),
  );
}

int _toInt(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime _toDate(dynamic value) {
  if (value == null) return DateTime.now();

  return DateTime.tryParse(value.toString()) ?? DateTime.now();
}
