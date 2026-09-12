import '../../donation/domain/donation.dart';

/// Result of a code entry attempt at handover — kept out of the exception
/// path because "wrong code, try again" is expected user input, not a bug.
enum CodeEntryResult { success, wrongCode, expired }

/// The allocation path — scope §15's "must resolve within seconds" flow.
///
/// In production this is a NestJS module driven by BullMQ, never blocking
/// behind a request (see `docs/ARCHITECTURE.md` §3). The fixture
/// implementation collapses that to a synchronous call so the screen layer
/// is written against the same shape either way.
abstract class AllocationRepository {
  /// A receiver requests a live donation. Resolves once ranked and
  /// allocated — real backend: BullMQ job + Socket.IO push; fixture:
  /// immediate single-candidate allocation.
  Future<Donation> requestDonation({
    required String donationId,
    required String ngoId,
    required String ngoName,
  });

  /// The receiver enters the 4-digit code at handover. This one exchange is
  /// the entire proof mechanism for v1 — no photo, no signature, no GPS.
  Future<CodeEntryResult> enterPickupCode({
    required String donationId,
    required String code,
  });
}
