import 'donation.dart';

/// Abstract interface — `data/` provides the implementation (fixtures today,
/// Dio + Drift once `apps/api` exists). Nothing above this import knows or
/// cares which.
abstract class DonationRepository {
  /// All donations belonging to [donorId], newest first.
  Stream<List<Donation>> watchDonorDonations(String donorId);

  Future<Donation> getById(String id);

  Future<Donation> create({
    required String donorId,
    required String donorName,
    required String title,
    String? description,
    required int portions,
    required DateTime pickupWindowStart,
    required DateTime pickupWindowEnd,
    required PickupAddress address,
  });

  Future<void> cancel(String id);
}
