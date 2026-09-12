import '../../donation/domain/donation.dart';

/// The receiver-side read model of the feed: `live` donations within reach,
/// masked to §11's locality-only view until an allocation names this NGO.
abstract class DiscoveryRepository {
  /// Live donations, nearest/newest first, excluding [excludeDonorId] so an
  /// NGO never sees its own posts (donors and receivers share the fixture
  /// store in dev; a real donor account never calls this).
  Stream<List<Donation>> watchLiveFeed({String? excludeDonorId});

  Future<Donation> getById(String id);
}
