
class Allocation {
  const Allocation({
    required this.id,
    required this.donationId,
    required this.status,
    required this.createdAt,
    this.donorId,
    this.ngoId,
    this.ngoName,
    this.requestedPortions = 0,
    this.offeredPortions,
    this.allocatedPortions = 0,
    this.pickupCode,
    this.pickupAddress,
    this.contactName,
    this.contactPhone,
    this.pickupLatitude,
    this.pickupLongitude,
    this.collectedAt,
  });

  final String id;
  final String donationId;

  final String? donorId;
  final String? ngoId;
  final String? ngoName;

  final String status;

  final int requestedPortions;
  final int? offeredPortions;
  final int allocatedPortions;

  /// Present in the NGO allocations response only.
  /// Never expose this value in the donor's allocation response.
  final String? pickupCode;

  /// Full pickup address and donor contact, set when the donor approves.
  /// Only the donor and the approved NGO receive these.
  final String? pickupAddress;
  final String? contactName;
  final String? contactPhone;

  /// Optional exact pickup point the donor pinned on approval.
  final double? pickupLatitude;
  final double? pickupLongitude;

  bool get hasPickupLocation =>
      pickupLatitude != null && pickupLongitude != null;

  final DateTime createdAt;
  final DateTime? collectedAt;

  bool get isApproved => status == 'approved';

  bool get isCollected => status == 'collected';

  factory Allocation.fromJson(Map<String, dynamic> json) {
    final donationData = json['donationId'];

    final donationId = donationData is Map
        ? donationData['_id']?.toString() ?? ''
        : donationData?.toString() ?? '';

    return Allocation(
      id: json['_id']?.toString() ?? '',
      donationId: donationId,
      donorId: json['donorId']?.toString(),
      ngoId: json['ngoId']?.toString(),
      ngoName: json['ngoName']?.toString(),
      status: json['status']?.toString() ?? 'unknown',
      requestedPortions: _toInt(json['requestedPortions']),
      offeredPortions: json['offeredPortions'] == null
          ? null
          : _toInt(json['offeredPortions']),
      allocatedPortions: _toInt(json['allocatedPortions']),
      pickupCode: json['pickupCode']?.toString(),
      pickupAddress: json['pickupAddress']?.toString(),
      contactName: json['contactName']?.toString(),
      contactPhone: json['contactPhone']?.toString(),
      pickupLatitude: _toDouble(json['pickupLatitude']),
      pickupLongitude: _toDouble(json['pickupLongitude']),
      createdAt: _toDate(json['createdAt']),
      collectedAt: json['collectedAt'] == null
          ? null
          : _toDate(json['collectedAt']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime _toDate(dynamic value) {
    if (value == null) return DateTime.now();
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
