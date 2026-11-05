import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_design_system/ss_design_system.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/providers.dart';
import '../../../../shared/widgets/async_error_view.dart';
import '../../../../shared/widgets/role_scaffold.dart';
import '../../../../shared/widgets/role_tabs.dart';
import '../../../auth/domain/user_role.dart';
import '../../domain/app_notification.dart';
import '../controllers/notification_providers.dart';

/// Alerts tab for donors and NGOs: what happened to their donations and
/// requests, newest first. Tapping an alert marks it read and opens the
/// screen where the user can act on it.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(sessionProvider);
    final isDonor = session?.role == UserRole.donor;
    final feedAsync = ref.watch(notificationsProvider);
    final unread = ref.watch(unreadAlertsCountProvider);

    return RoleScaffold(
      currentIndex: 3,
      tabs: isDonor ? donorTabs(l10n) : receiverTabs(l10n),
      appBarTitle: l10n.notificationsTitle,
      appBarActions: [
        if (unread > 0)
          TextButton(
            key: const Key('markAllReadButton'),
            onPressed: () => _markAllRead(context, ref),
            child: const Text('Mark all read'),
          ),
      ],
      body: feedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => AsyncErrorView(
          error: err,
          onRetry: () => ref.invalidate(notificationsProvider),
        ),
        data: (feed) {
          if (feed.items.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => ref.refresh(notificationsProvider.future),
              child: ListView(
                children: [
                  const SizedBox(height: SsSpacing.xxl),
                  SsEmptyState(
                    title: l10n.notificationsEmptyTitle,
                    message: l10n.notificationsEmptyMessage,
                    illustration: SsIllustrations.nothingHereYet,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(notificationsProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.all(SsSpacing.lg),
              itemCount: feed.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: SsSpacing.sm),
              itemBuilder: (context, i) {
                final n = feed.items[i];
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
                  onTap: () => _open(context, ref, n, isDonor: isDonor),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _markAllRead(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(notificationRepositoryProvider).markAllRead();
    } catch (error) {
      if (context.mounted) _showError(context, error);
    }
    ref.invalidate(notificationsProvider);
  }

  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    AppNotification n, {
    required bool isDonor,
  }) async {
    if (!n.read) {
      try {
        await ref.read(notificationRepositoryProvider).markRead(n.id);
      } catch (_) {
        // Opening the related screen matters more than the read flag.
      }
      ref.invalidate(notificationsProvider);
    }

    if (!context.mounted) return;

    final donationId = n.donationId;

    if (isDonor) {
      if (donationId != null && donationId.isNotEmpty) {
        context.pushNamed(
          'donorDonationDetail',
          pathParameters: {'id': donationId},
        );
      }
      return;
    }

    switch (n.type) {
      case 'reduced_offer' || 'request_approved':
        context.goNamed('receiverRequests');
      case 'request_rejected' || 'request_closed' || 'pickup_completed':
        context.goNamed('receiverHistory');
      case 'ngo_verified':
        context.goNamed('receiverFeed');
    }
  }

  void _showError(BuildContext context, Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.toString().replaceFirst('Exception: ', '')),
        backgroundColor: Colors.red,
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
