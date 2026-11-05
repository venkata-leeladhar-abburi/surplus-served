// Read models for the admin API (apps/backend/controllers/adminController.js).

DateTime? _date(dynamic v) =>
    v == null ? null : DateTime.tryParse(v.toString())?.toLocal();

int _int(dynamic v) =>
    v is num ? v.toInt() : int.tryParse(v?.toString() ?? '') ?? 0;

/// An NGO account as the admin sees it, including its certificate link.
class NgoApplication {
  const NgoApplication({
    required this.id,
    required this.contactName,
    required this.email,
    required this.organizationName,
    required this.registrationNumber,
    required this.verificationStatus,
    this.documentUrl,
    this.rejectionReason,
    this.createdAt,
  });

  final String id;
  final String contactName;
  final String email;
  final String organizationName;
  final String registrationNumber;

  /// pending | verified | rejected
  final String verificationStatus;
  final String? documentUrl;
  final String? rejectionReason;
  final DateTime? createdAt;

  bool get isPending => verificationStatus == 'pending';

  /// Certificates uploaded as PDF are stored as Cloudinary "raw" files.
  bool get isPdf => documentUrl?.toLowerCase().contains('/raw/') == true ||
      documentUrl?.toLowerCase().endsWith('.pdf') == true;

  factory NgoApplication.fromJson(Map<String, dynamic> json) {
    final details = json['ngoDetails'] is Map
        ? Map<String, dynamic>.from(json['ngoDetails'] as Map)
        : <String, dynamic>{};

    return NgoApplication(
      id: json['_id']?.toString() ?? '',
      contactName: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      organizationName: details['organizationName']?.toString() ?? '',
      registrationNumber: details['registrationNumber']?.toString() ?? '',
      // /ngos/pending does not return the status field; those are pending.
      verificationStatus:
          details['verificationStatus']?.toString() ?? 'pending',
      documentUrl: details['documentUrl']?.toString(),
      rejectionReason: details['rejectionReason']?.toString(),
      createdAt: _date(json['createdAt']),
    );
  }
}

class AdminStats {
  const AdminStats({
    required this.donors,
    required this.ngosPending,
    required this.ngosVerified,
    required this.ngosRejected,
    required this.donationsTotal,
    required this.donationsAvailable,
    required this.donationsClaimed,
    required this.donationsCollected,
    required this.donationsCancelled,
    required this.requestsActive,
    required this.requestsCollected,
    required this.portionsServed,
  });

  final int donors;
  final int ngosPending;
  final int ngosVerified;
  final int ngosRejected;
  final int donationsTotal;
  final int donationsAvailable;
  final int donationsClaimed;
  final int donationsCollected;
  final int donationsCancelled;
  final int requestsActive;
  final int requestsCollected;
  final int portionsServed;

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> part(String key) => json[key] is Map
        ? Map<String, dynamic>.from(json[key] as Map)
        : <String, dynamic>{};

    final users = part('users');
    final donations = part('donations');
    final requests = part('requests');

    return AdminStats(
      donors: _int(users['donors']),
      ngosPending: _int(users['ngosPending']),
      ngosVerified: _int(users['ngosVerified']),
      ngosRejected: _int(users['ngosRejected']),
      donationsTotal: _int(donations['total']),
      donationsAvailable: _int(donations['available']),
      donationsClaimed: _int(donations['claimed']),
      donationsCollected: _int(donations['collected']),
      donationsCancelled: _int(donations['cancelled']),
      requestsActive: _int(requests['active']),
      requestsCollected: _int(requests['collected']),
      portionsServed: _int(json['portionsServed']),
    );
  }
}

/// One donation request, as shown in the admin activity feed.
class AdminActivity {
  const AdminActivity({
    required this.id,
    required this.ngoName,
    required this.donationTitle,
    required this.donorName,
    required this.status,
    required this.portions,
    this.updatedAt,
  });

  final String id;
  final String ngoName;
  final String donationTitle;
  final String donorName;
  final String status;
  final int portions;
  final DateTime? updatedAt;

  factory AdminActivity.fromJson(Map<String, dynamic> json) {
    final donation = json['donationId'] is Map
        ? Map<String, dynamic>.from(json['donationId'] as Map)
        : <String, dynamic>{};

    final allocated = _int(json['allocatedPortions']);

    return AdminActivity(
      id: json['_id']?.toString() ?? '',
      ngoName: json['ngoName']?.toString() ?? 'NGO',
      donationTitle: donation['title']?.toString() ?? 'Donation',
      donorName: donation['donorName']?.toString() ?? 'Donor',
      status: json['status']?.toString() ?? '',
      portions: allocated > 0 ? allocated : _int(json['requestedPortions']),
      updatedAt: _date(json['updatedAt']),
    );
  }
}

/// A donation as listed for the admin.
class AdminDonation {
  const AdminDonation({
    required this.id,
    required this.title,
    required this.donorName,
    required this.locality,
    required this.status,
    required this.portions,
    required this.remainingPortions,
    this.createdAt,
  });

  final String id;
  final String title;
  final String donorName;
  final String locality;

  /// available | claimed | collected | cancelled
  final String status;
  final int portions;
  final int remainingPortions;
  final DateTime? createdAt;

  factory AdminDonation.fromJson(Map<String, dynamic> json) {
    final address = json['address'] is Map
        ? Map<String, dynamic>.from(json['address'] as Map)
        : <String, dynamic>{};

    return AdminDonation(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      donorName: json['donorName']?.toString() ?? '',
      locality: address['locality']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      portions: _int(json['portions']),
      remainingPortions: _int(json['remainingPortions']),
      createdAt: _date(json['createdAt']),
    );
  }
}
