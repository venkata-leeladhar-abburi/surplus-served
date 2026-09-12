import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_design_system/ss_design_system.dart';

import '../../../../shared/utils/status_mapper.dart';
import '../../../../shared/widgets/role_scaffold.dart';
import '../../../../shared/widgets/role_tabs.dart';
import '../../../discovery/presentation/controllers/receiver_donations_providers.dart';

class ReceiverHistoryScreen extends ConsumerWidget {
  const ReceiverHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final donationsAsync = ref.watch(receiverDonationsProvider);

    return RoleScaffold(
      currentIndex: 2,
      tabs: receiverTabs,
      appBarTitle: 'History',
      body: donationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Something went wrong: $err')),
        data: (allDonations) {
          final history = allDonations.where((d) => !d.status.isActive).toList();
          if (history.isEmpty) {
            return Center(
              child: SsEmptyState(
                title: 'Nothing collected yet',
                message: 'Donations you\'ve collected will show up here.',
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
                subtitle: 'From ${d.donorName} · ${d.createdAt.day}/${d.createdAt.month}',
                trailing: SsStatusBadge(status: d.status.ssStatus, dense: true),
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
