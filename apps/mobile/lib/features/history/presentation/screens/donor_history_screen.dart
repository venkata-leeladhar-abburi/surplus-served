import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_design_system/ss_design_system.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../shared/utils/status_mapper.dart';
import '../../../../shared/widgets/role_scaffold.dart';
import '../../../../shared/widgets/role_tabs.dart';
import '../../../donation/presentation/controllers/donation_providers.dart';

/// Terminal donations only — collected, cancelled, unfulfilled, rejected.
/// The dashboard tab is "what's in flight"; this is the record of it.
class DonorHistoryScreen extends ConsumerWidget {
  const DonorHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final donationsAsync = ref.watch(donorDonationsProvider);

    return RoleScaffold(
      currentIndex: 2,
      tabs: donorTabs(l10n),
      appBarTitle: l10n.historyTitle,
      body: donationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text(l10n.commonError('$err'))),
        data: (allDonations) {
          final history = allDonations.where((d) => !d.status.isActive).toList();
          if (history.isEmpty) {
            return Center(
              child: SsEmptyState(
                title: l10n.donorHistoryEmptyTitle,
                message: l10n.donorHistoryEmptyMessage,
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
                subtitle: l10n.historyDonorSubtitle(d.portions, d.createdAt.day, d.createdAt.month),
                trailing: SsStatusBadge(
                  status: d.status.ssStatus,
                  label: d.status.label(l10n),
                  dense: true,
                ),
                onTap: () => context.pushNamed(
                  'donorDonationDetail',
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
