import 'package:flutter_test/flutter_test.dart';
import 'package:surplus_served_mobile/features/allocation/data/allocation_repository_fixture.dart';
import 'package:surplus_served_mobile/features/allocation/domain/allocation_repository.dart';
import 'package:surplus_served_mobile/features/donation/data/donation_repository_fixture.dart';
import 'package:surplus_served_mobile/features/donation/domain/donation.dart';
import 'package:surplus_served_mobile/features/donation/domain/donation_status.dart';
import 'package:surplus_served_mobile/shared/fixtures/fixture_store.dart';

/// Exercises the vertical slice's backbone against the same fixture store
/// the screens use: post → live → request → allocated → code → collected.
void main() {
  test('a donation can be posted, requested and collected end to end', () async {
    final store = FixtureStore.instance;
    final donationRepo = DonationRepositoryFixture(store);
    final AllocationRepository allocationRepo = AllocationRepositoryFixture(store);

    final donation = await donationRepo.create(
      donorId: 'donor-test',
      donorName: 'Test Kitchen',
      title: 'Rice and dal',
      portions: 10,
      pickupWindowStart: DateTime.now(),
      pickupWindowEnd: DateTime.now().add(const Duration(hours: 1)),
      address: const PickupAddress(locality: 'Test Locality'),
    );
    expect(donation.status, DonationStatus.live);
    expect(donation.address.hasExactDetails, isFalse); // §11 masked while live

    final allocated = await allocationRepo.requestDonation(
      donationId: donation.id,
      ngoId: 'ngo-test',
      ngoName: 'Test NGO',
    );
    expect(allocated.status, DonationStatus.allocated);
    expect(allocated.pickupCode, hasLength(4));
    expect(allocated.address.hasExactDetails, isTrue); // §11 revealed once allocated

    final wrongAttempt = await allocationRepo.enterPickupCode(
      donationId: donation.id,
      code: '0000',
    );
    expect(wrongAttempt, CodeEntryResult.wrongCode);

    final result = await allocationRepo.enterPickupCode(
      donationId: donation.id,
      code: allocated.pickupCode!,
    );
    expect(result, CodeEntryResult.success);

    final collected = await donationRepo.getById(donation.id);
    expect(collected.status, DonationStatus.collected);
  });
}
