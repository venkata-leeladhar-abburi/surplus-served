
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
}
