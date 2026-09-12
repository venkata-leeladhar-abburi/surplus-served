import 'app_notification.dart';

abstract class NotificationRepository {
  /// Real backend: FCM push, mirrored into a per-user feed (ARCHITECTURE.md
  /// §3 `notifications/`). The fixture keeps a small static feed per role.
  Stream<List<AppNotification>> watchForUser(String userId);

  Future<void> markRead(String id);
}
