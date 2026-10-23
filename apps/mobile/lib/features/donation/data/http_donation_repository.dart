import 'donation_status.dart';

/// A pickup address as it should be *serialised*, not as it is stored.
///
/// §11 (address privacy): while a donation is `live`, only [locality] is
/// visible to receivers browsing the feed. [exactLine] and [contactPhone]
/// are populated only once an NGO holds the allocation for this donation —
/// enforced by the repository/serializer, never trusted to a screen.
class PickupAddress {
  const PickupAddress({
    required this.locality,
    this.exactLine,
    this.contactName,
    this.contactPhone,
    this.latitude,
    this.longitude,
  });

  final String locality;
  final String? exactLine;
  final String? contactName;
  final String? contactPhone;
  final double? latitude;
  final double? longitude;

  bool get hasExactDetails => exactLine != null;
}

class Donation {
  const Donation({
    required this.id,
    required this.donorId,
    required this.donorName,
    required this.title,
    required this.portions,
    required this.status,
    required this.pickupWindowStart,
    required this.pickupWindowEnd,
    required this.address,
    required this.createdAt,
    this.description,
    this.allocatedToNgoId,
    this.allocatedToNgoName,
    this.pickupCode,
  });

  final String id;
  final String donorId;
  final String donorName;
  final String title;
  final String? description;
  final int portions;
  final DonationStatus status;
  final DateTime pickupWindowStart;
  final DateTime pickupWindowEnd;
  final PickupAddress address;
  final DateTime createdAt;

  final String? allocatedToNgoId;
  final String? allocatedToNgoName;

  /// §12's 4-digit handover proof. Set once allocated, cleared once
  /// collected — the entire proof mechanism for v1, no photo or GPS trail.
  final String? pickupCode;

  /// Minutes remaining in the pickup window, floored at zero. Feeds
  /// `SsFreshnessRing` — green → orange → red as this shrinks.
  int minutesRemaining(DateTime now) {
    final remaining = pickupWindowEnd.difference(now).inMinutes;
    return remaining < 0 ? 0 : remaining;
  }

  Donation copyWith({
    DonationStatus? status,
    String? allocatedToNgoId,
    String? allocatedToNgoName,
    String? pickupCode,
    PickupAddress? address,
  }) {
    return Donation(
      id: id,
      donorId: donorId,
      donorName: donorName,
      title: title,
      description: description,
      portions: portions,
      status: status ?? this.status,
      pickupWindowStart: pickupWindowStart,
      pickupWindowEnd: pickupWindowEnd,
      address: address ?? this.address,
      createdAt: createdAt,
      allocatedToNgoId: allocatedToNgoId ?? this.allocatedToNgoId,
      allocatedToNgoName: allocatedToNgoName ?? this.allocatedToNgoName,
      pickupCode: pickupCode ?? this.pickupCode,
    );
  }
}
