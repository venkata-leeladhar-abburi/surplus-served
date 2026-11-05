import 'app_notification.dart';

/// In-app alerts stored by the backend (/api/notifications).
abstract class NotificationRepository {
  Future<NotificationFeed> fetch();

  Future<void> markRead(String id);

  Future<void> markAllRead();
}
