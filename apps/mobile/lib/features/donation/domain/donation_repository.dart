import 'donation.dart';
import 'pickup_address.dart';

abstract class DonationRepository {
  Stream<List<Donation>> watchDonorDonations(String donorId, {String? authToken});

  Future<Donation> getById(String id, {String? authToken});

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
  });

  Future<void> cancel(String id, {String? authToken});
}
