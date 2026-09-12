import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_design_system/ss_design_system.dart';

import '../../../../core/providers.dart';
import '../../../../shared/widgets/role_scaffold.dart';
import '../../../../shared/widgets/role_tabs.dart';
import '../../../auth/domain/user_role.dart';
import '../../domain/app_notification.dart';
import '../controllers/notification_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final isDonor = session?.role == UserRole.donor;
    final notificationsAsync = ref.watch(notificationsProvider);

    return RoleScaffold(
      currentIndex: 3,
      tabs: isDonor ? donorTabs : receiverTabs,
      appBarTitle: 'Notifications',
      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Something went wrong: $err')),
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: SsEmptyState(
                title: 'Nothing yet',
                message: "We'll let you know the moment something needs your attention.",
                illustration: SsIllustrations.nothingHereYet,
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(SsSpacing.lg),
            itemCount: notifications.length,
            separatorBuilder: (_, _) => const SizedBox(height: SsSpacing.sm),
            itemBuilder: (context, i) {
              final n = notifications[i];
              return SsNotificationTile(
                title: n.title,
                body: n.body,
                timeAgo: _relativeTime(n.createdAt),
                unread: !n.read,
                tone: switch (n.tone) {
                  NotificationTone.success => SsNotificationTone.success,
                  NotificationTone.warning => SsNotificationTone.warning,
                  NotificationTone.info => SsNotificationTone.neutral,
                },
                icon: switch (n.tone) {
                  NotificationTone.success => SsIcons.check,
                  NotificationTone.warning => SsIcons.alert,
                  NotificationTone.info => SsIcons.bell,
                },
                onTap: () => ref.read(notificationRepositoryProvider).markRead(n.id),
              );
            },
          );
        },
      ),
    );
  }

  String _relativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
