import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_design_system/ss_design_system.dart';

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
    final donationsAsync = ref.watch(donorDonationsProvider);

    return RoleScaffold(
      currentIndex: 2,
      tabs: donorTabs,
      appBarTitle: 'History',
      body: donationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Something went wrong: $err')),
        data: (allDonations) {
          final history = allDonations.where((d) => !d.status.isActive).toList();
          if (history.isEmpty) {
            return Center(
              child: SsEmptyState(
                title: 'Nothing here yet',
                message: 'Donations move here once they\'re collected, cancelled or expired.',
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
                subtitle: '${d.portions} portions · ${d.createdAt.day}/${d.createdAt.month}',
                trailing: SsStatusBadge(status: d.status.ssStatus, dense: true),
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
