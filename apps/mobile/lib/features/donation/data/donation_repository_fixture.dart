import '../../../shared/fixtures/fixture_store.dart';
import '../domain/donation.dart';
import '../domain/donation_repository.dart';

class DonationRepositoryFixture implements DonationRepository {
  DonationRepositoryFixture(this._store);

  final FixtureStore _store;

  @override
  Stream<List<Donation>> watchDonorDonations(String donorId) {
    return _store.watchAll().map(
      (all) =>
          all.where((d) => d.donorId == donorId).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
    );
  }

  @override
  Future<Donation> getById(String id) async => _store.getById(id);

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
  }) async {
    return _store.create(
      donorId: donorId,
      donorName: donorName,
      title: title,
      description: description,
      portions: portions,
      pickupWindowStart: pickupWindowStart,
      pickupWindowEnd: pickupWindowEnd,
      address: address,
    );
  }

  @override
  Future<void> cancel(String id) async => _store.cancel(id);
}
