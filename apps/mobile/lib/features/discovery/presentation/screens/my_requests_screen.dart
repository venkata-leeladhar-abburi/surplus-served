import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_design_system/ss_design_system.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../shared/utils/status_mapper.dart';
import '../../../../shared/widgets/async_error_view.dart';
import '../../../../shared/widgets/role_scaffold.dart';
import '../../../../shared/widgets/role_tabs.dart';
import '../../../donation/domain/donation_status.dart';
import '../controllers/receiver_donations_providers.dart';

/// Donations this NGO holds right now — allocated and awaiting handover.
/// Once collected, a donation moves to the History tab.
class MyRequestsScreen extends ConsumerWidget {
  const MyRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final donationsAsync = ref.watch(receiverDonationsProvider);

    return RoleScaffold(
      currentIndex: 1,
      tabs: receiverTabs(l10n),
      appBarTitle: l10n.receiverRequestsTitle,
      body: donationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => AsyncErrorView(
          error: err,
          onRetry: () => ref.invalidate(receiverDonationsProvider),
        ),
        data: (allDonations) {
          final active = allDonations
              .where(
                (d) =>
                    d.status == DonationStatus.allocated ||
                    d.status == DonationStatus.reallocated,
              )
              .toList();
          if (active.isEmpty) {
            return Center(
              child: SsEmptyState(
                title: l10n.receiverRequestsEmptyTitle,
                message: l10n.receiverRequestsEmptyMessage,
                illustration: SsIllustrations.noRequestsYet,
                primaryActionLabel: l10n.receiverBrowseCta,
                onPrimaryAction: () => context.goNamed('receiverFeed'),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(SsSpacing.lg),
            itemCount: active.length,
            separatorBuilder: (_, _) => const SizedBox(height: SsSpacing.md),
            itemBuilder: (context, i) {
              final d = active[i];
              return SsListTile(
                title: d.title,
                subtitle: l10n.receiverRequestSubtitle(d.donorName, d.portions),
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
