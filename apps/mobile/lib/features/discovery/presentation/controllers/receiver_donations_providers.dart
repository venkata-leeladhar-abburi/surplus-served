
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../../core/providers.dart';
import '../../../donation/domain/donation.dart';
import '../../../donation/domain/donation_status.dart';

final receiverDonationsProvider = StreamProvider<List<Donation>>((ref) {
  final session = ref.watch(sessionProvider);

  if (session == null || session.token == null || session.token!.isEmpty) {
    return Stream.error(Exception('Please log in to view your requests.'));
  }

  return Stream.fromFuture(
    _fetchMyAllocations(
      session.userId,
      session.token!,
    ),
  );
});

Future<List<Donation>> _fetchMyAllocations(
  String ngoId,
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

  final decoded = jsonDecode(response.body);

  if (response.statusCode != 200) {
    final message = decoded is Map
        ? decoded['message']?.toString()
        : null;

    throw Exception(message ?? 'Unable to load your requests.');
  }

  if (decoded is! Map || decoded['allocations'] is! List) {
    throw Exception('Invalid allocations response from server.');
  }

  final allocations = decoded['allocations'] as List;

  final donations = <Donation>[];

  for (final item in allocations) {
    if (item is! Map) continue;

    // Only approved allocations are currently awaiting pickup.
    if (item['status']?.toString() != 'approved') continue;

    final donationData = item['donationId'];

    if (donationData is! Map) {
      throw Exception(
        'Donation details were not included in the allocation response.',
      );
    }

    final donation = Map<String, dynamic>.from(donationData);
    final addressData = donation['address'];

    final address = addressData is Map
        ? Map<String, dynamic>.from(addressData)
        : <String, dynamic>{};

    final portions = _toInt(item['allocatedPortions']);

    if (portions <= 0) continue;

    donations.add(
      Donation(
        id: donation['_id']?.toString() ?? '',
        donorId: donation['donorId']?.toString() ?? '',
        donorName: donation['donorName']?.toString() ?? 'Donor',
        title: donation['title']?.toString() ?? 'Food donation',
        description: donation['description']?.toString(),
        portions: portions,
        status: DonationStatus.allocated,
        pickupWindowStart: _toDate(donation['pickupWindowStart']),
        pickupWindowEnd: _toDate(donation['pickupWindowEnd']),
        address: PickupAddress(
          locality: address['locality']?.toString() ?? '',
          exactLine: address['exactLine']?.toString(),
          contactName: address['contactName']?.toString(),
          contactPhone: address['contactPhone']?.toString(),
          latitude: (address['latitude'] as num?)?.toDouble(),
          longitude: (address['longitude'] as num?)?.toDouble(),
        ),
        createdAt: _toDate(item['createdAt']),
        allocatedToNgoId: ngoId,
        allocatedToNgoName: item['ngoName']?.toString(),
      ),
    );
  }

  donations.sort(
    (a, b) => b.createdAt.compareTo(a.createdAt),
  );

  return donations;
}

int _toInt(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime _toDate(dynamic value) {
  if (value == null) return DateTime.now();

  return DateTime.tryParse(value.toString()) ?? DateTime.now();
}
