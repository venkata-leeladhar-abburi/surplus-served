import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_design_system/ss_design_system.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../shared/utils/status_mapper.dart';
import '../../../../shared/widgets/async_error_view.dart';
import '../../../../shared/widgets/role_scaffold.dart';
import '../../../../shared/widgets/role_tabs.dart';
import '../../../discovery/presentation/controllers/receiver_donations_providers.dart';

class ReceiverHistoryScreen extends ConsumerWidget {
  const ReceiverHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final donationsAsync = ref.watch(receiverDonationsProvider);

    return RoleScaffold(
      currentIndex: 2,
      tabs: receiverTabs(l10n),
      appBarTitle: l10n.historyTitle,
      body: donationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => AsyncErrorView(
          error: err,
          onRetry: () => ref.invalidate(receiverDonationsProvider),
        ),
        data: (allDonations) {
          final history = allDonations
              .where((d) => !d.status.isActive)
              .toList();
          if (history.isEmpty) {
            return Center(
              child: SsEmptyState(
                title: l10n.receiverHistoryEmptyTitle,
                message: l10n.receiverHistoryEmptyMessage,
                illustration: SsIllustrations.noResultsFound,
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(SsSpacing.lg),
            itemCount: history.length,
            separatorBuilder: (_, _) => const SizedBox(height: SsSpacing.md),
            itemBuilder: (context, i) {
              final d = history[i];
              return SsListTile(
                title: d.title,
                subtitle: l10n.historyReceiverSubtitle(
                  d.donorName,
                  d.createdAt.day,
                  d.createdAt.month,
                ),
                trailing: SsStatusBadge(
                  status: d.status.ssStatus,
                  label: d.status.label(l10n),
                  dense: true,
                ),
                onTap: () => context.pushNamed(
                  'receiverDonationDetail',
                  pathParameters: {'id': d.id},
                ),
              );
            },
          );
        },
      ),
    );
  }
}
