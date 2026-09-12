import '../../../shared/fixtures/fixture_store.dart';
import '../../donation/domain/donation.dart';
import '../domain/allocation_repository.dart';

class AllocationRepositoryFixture implements AllocationRepository {
  AllocationRepositoryFixture(this._store);

  final FixtureStore _store;

  @override
  Future<Donation> requestDonation({
    required String donationId,
    required String ngoId,
    required String ngoName,
  }) async {
    // Real backend: BullMQ `allocate` job over a PostGIS candidate set,
    // pushed via Socket.IO/FCM (ARCHITECTURE.md §3). Fixture: synchronous.
    return _store.allocate(donationId: donationId, ngoId: ngoId, ngoName: ngoName);
  }

  @override
  Future<CodeEntryResult> enterPickupCode({
    required String donationId,
    required String code,
  }) async {
    final result = _store.enterPickupCode(donationId: donationId, code: code);
    return result.matched ? CodeEntryResult.success : CodeEntryResult.wrongCode;
  }
}
