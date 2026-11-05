import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers.dart';
import '../../domain/app_notification.dart';

/// The logged-in user's alerts. Refreshed on tab switches, pull to refresh
/// and after marking alerts read.
final notificationsProvider = FutureProvider<NotificationFeed>((ref) async {
  final session = ref.watch(sessionProvider);
  if (session == null) return NotificationFeed.empty;
  return ref.watch(notificationRepositoryProvider).fetch();
});

/// Unread count for the Alerts tab badge (0 while loading or on error).
final unreadAlertsCountProvider = Provider<int>((ref) {
  return ref
          .watch(notificationsProvider)
          .whenOrNull(data: (feed) => feed.unreadCount) ??
      0;
});
