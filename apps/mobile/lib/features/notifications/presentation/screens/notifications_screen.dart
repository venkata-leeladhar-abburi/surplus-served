import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_design_system/ss_design_system.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/providers.dart';
import '../../../../shared/widgets/async_error_view.dart';
import '../../../../shared/widgets/role_scaffold.dart';
import '../../../../shared/widgets/role_tabs.dart';
import '../../../auth/domain/user_role.dart';
import '../../domain/app_notification.dart';
import '../controllers/notification_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(sessionProvider);
    final isDonor = session?.role == UserRole.donor;
    final notificationsAsync = ref.watch(notificationsProvider);

    return RoleScaffold(
      currentIndex: 3,
      tabs: isDonor ? donorTabs(l10n) : receiverTabs(l10n),
      appBarTitle: l10n.notificationsTitle,
      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => AsyncErrorView(
          error: err,
          onRetry: () => ref.invalidate(notificationsProvider),
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: SsEmptyState(
                title: l10n.notificationsEmptyTitle,
                message: l10n.notificationsEmptyMessage,
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
                timeAgo: _relativeTime(n.createdAt, l10n),
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
                onTap: () =>
                    ref.read(notificationRepositoryProvider).markRead(n.id),
              );
            },
          );
        },
      ),
    );
  }

  String _relativeTime(DateTime time, AppLocalizations l10n) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return l10n.notifTimeMinutes(diff.inMinutes);
    if (diff.inHours < 24) return l10n.notifTimeHours(diff.inHours);
    return l10n.notifTimeDays(diff.inDays);
  }
}
