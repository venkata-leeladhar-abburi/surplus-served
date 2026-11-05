
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

/// Fetches every allocation (donation request) belonging to the logged-in
/// NGO, in all statuses, newest first. Screens split them into active
/// requests and history using `AllocationStatusView.isActive`.
///
/// The pickup code is only present while the allocation is `approved`.
final receiverAllocationsProvider =
    FutureProvider<List<ReceiverAllocation>>((ref) async {
  final session = ref.watch(sessionProvider);

  if (session == null || session.token == null || session.token!.isEmpty) {
    throw Exception('Please log in to view your requests.');
  }

  final allocations = await _fetchMyAllocations(session.token!);

  final results = <ReceiverAllocation>[];

  for (final item in allocations) {
    final donationData = item['donationId'];

    // A donation can be missing if it was removed from the database;
    // skip that allocation rather than failing the whole list.
    if (donationData is! Map) continue;

    final allocation = Allocation.fromJson(item);

    if (allocation.id.isEmpty || allocation.donationId.isEmpty) continue;

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

  final allocatedPortions = _toInt(allocationData['allocatedPortions']);
  final portions = allocatedPortions > 0
      ? allocatedPortions
      : _toInt(
          allocationData['offeredPortions'] ??
              allocationData['requestedPortions'],
        );

  return Donation(
    id: donationData['_id']?.toString() ?? '',
    donorId: allocationData['donorId']?.toString() ?? '',
    donorName: donationData['donorName']?.toString() ?? 'Donor',
    title: donationData['title']?.toString() ?? 'Food donation',
    description: donationData['description']?.toString(),
    portions: portions,
    imageUrl: donationData['imageUrl']?.toString(),
    foodCategory: donationData['foodCategory']?.toString() ?? 'other',
    dietType: donationData['dietType']?.toString(),
    expiresAt: donationData['expiresAt'] != null
        ? DateTime.tryParse(donationData['expiresAt'].toString())
        : null,
    status: _donationStatusFor(allocationData['status']?.toString()),
    pickupWindowStart: _toDate(donationData['pickupWindowStart']),
    pickupWindowEnd: _toDate(donationData['pickupWindowEnd']),
    address: PickupAddress(
      locality: address['locality']?.toString() ?? '',
      exactLine: allocationData['pickupAddress']?.toString(),
      contactName: allocationData['contactName']?.toString(),
      contactPhone: allocationData['contactPhone']?.toString(),
      latitude: (address['latitude'] as num?)?.toDouble(),
      longitude: (address['longitude'] as num?)?.toDouble(),
    ),
    createdAt: _toDate(allocationData['createdAt']),
    allocatedToNgoId: ngoId,
    allocatedToNgoName: allocationData['ngoName']?.toString(),
  );
}

/// Approximate donation status from this NGO's point of view, used by
/// screens that still display a `DonationStatus`.
DonationStatus _donationStatusFor(String? allocationStatus) =>
    switch (allocationStatus) {
      'approved' => DonationStatus.allocated,
      'collected' => DonationStatus.collected,
      'rejected' => DonationStatus.rejected,
      'declined' || 'cancelled' => DonationStatus.cancelled,
      'expired' => DonationStatus.unfulfilled,
      _ => DonationStatus.live,
    };

int _toInt(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime _toDate(dynamic value) {
  if (value == null) return DateTime.now();

  return DateTime.tryParse(value.toString()) ?? DateTime.now();
}
