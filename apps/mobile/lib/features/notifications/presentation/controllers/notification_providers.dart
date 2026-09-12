import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers.dart';
import '../../domain/app_notification.dart';

final notificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  final session = ref.watch(sessionProvider);
  if (session == null) return const Stream.empty();
  return ref.watch(notificationRepositoryProvider).watchForUser(session.userId);
});
