import '../../../shared/fixtures/fixture_store.dart';
import '../../donation/domain/donation.dart';
import '../../donation/domain/donation_status.dart';
import '../domain/discovery_repository.dart';

class DiscoveryRepositoryFixture implements DiscoveryRepository {
  DiscoveryRepositoryFixture(this._store);

  final FixtureStore _store;

  @override
  Stream<List<Donation>> watchLiveFeed({String? excludeDonorId}) {
    return _store.watchAll().map(
      (all) =>
          all
              .where(
                (d) =>
                    d.status == DonationStatus.live &&
                    d.donorId != excludeDonorId,
              )
              .toList()
            ..sort((a, b) => a.pickupWindowEnd.compareTo(b.pickupWindowEnd)),
    );
  }

  @override
  Future<Donation> getById(String id) async => _store.getById(id);
}
