
import '../../donation/domain/donation.dart';

enum CodeEntryResult {
  success,
  wrongCode,
  expired,
}

abstract class AllocationRepository {
  // NGO requests a specific number of portions.
  Future<Donation> requestDonation({
    required String donationId,
    required String ngoId,
    required String ngoName,
    required int requestedPortions,
  });

  // NGO responds to a reduced-portion offer.
  Future<void> confirmOffer({
    required String allocationId,
    required bool accept,
  });

  // Donor approves an NGO allocation and shares the full pickup address
  // and a contact phone number with that NGO.
  Future<void> approveAllocation({
    required String allocationId,
    required String pickupAddress,
    required String contactPhone,
    String? contactName,
    double? pickupLatitude,
    double? pickupLongitude,
  });

  // Donor rejects an NGO allocation.

  Future<void> rejectAllocation({
    required String allocationId,
  });

  // Donor verifies the six-digit pickup code.
  Future<void> verifyPickupCode({
    required String allocationId,
    required String code,
  });

  // Retained temporarily for compatibility with the existing screen.
  Future<CodeEntryResult> enterPickupCode({
    required String donationId,
    required String code,
  });
}
