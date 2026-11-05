
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
    required int requestedPortions,
  }) async {
    return _store.allocate(
      donationId: donationId,
      ngoId: ngoId,
      ngoName: ngoName,
    );
  }

  @override
  Future<void> confirmOffer({
    required String allocationId,
    required bool accept,
  }) async {
    throw UnsupportedError(
      'Offer confirmation requires the backend repository.',
    );
  }

  @override
  Future<void> approveAllocation({
    required String allocationId,
    required String pickupAddress,
    required String contactPhone,
    String? contactName,
    double? pickupLatitude,
    double? pickupLongitude,
  }) async {
    throw UnsupportedError(
      'Allocation approval requires the backend repository.',
    );
  }

  @override
  Future<void> rejectAllocation({
    required String allocationId,
  }) async {
    throw UnsupportedError(
      'Allocation rejection requires the backend repository.',
    );
  }

  @override
  Future<void> verifyPickupCode({
    required String allocationId,
    required String code,
  }) async {
    throw UnsupportedError(
      'Pickup verification requires the backend repository.',
    );
  }

  @override
  Future<CodeEntryResult> enterPickupCode({
    required String donationId,
    required String code,
  }) async {
    final result = _store.enterPickupCode(
      donationId: donationId,
      code: code,
    );

    return result.matched
        ? CodeEntryResult.success
        : CodeEntryResult.wrongCode;
  }
}
