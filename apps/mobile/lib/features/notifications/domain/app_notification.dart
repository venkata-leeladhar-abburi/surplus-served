enum NotificationTone { info, success, warning }

/// One in-app alert from GET /api/notifications.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.donationId,
    this.allocationId,
    this.read = false,
  });

  final String id;

  /// Backend event type, e.g. request_to_review, request_approved.
  final String type;
  final String title;
  final String body;
  final DateTime createdAt;
  final String? donationId;
  final String? allocationId;
  final bool read;

  NotificationTone get tone => switch (type) {
        'request_approved' ||
        'pickup_completed' ||
        'ngo_verified' =>
          NotificationTone.success,
        'reduced_offer' ||
        'request_rejected' ||
        'request_closed' =>
          NotificationTone.warning,
        _ => NotificationTone.info,
      };

  AppNotification copyWith({bool? read}) => AppNotification(
        id: id,
        type: type,
        title: title,
        body: body,
        createdAt: createdAt,
        donationId: donationId,
        allocationId: allocationId,
        read: read ?? this.read,
      );

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['_id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'info',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '')
              ?.toLocal() ??
          DateTime.now(),
      donationId: json['donationId']?.toString(),
      allocationId: json['allocationId']?.toString(),
      read: json['read'] == true,
    );
  }
}

/// The user's latest alerts and how many are unread.
class NotificationFeed {
  const NotificationFeed({required this.items, required this.unreadCount});

  static const empty = NotificationFeed(items: [], unreadCount: 0);

  final List<AppNotification> items;
  final int unreadCount;
}
