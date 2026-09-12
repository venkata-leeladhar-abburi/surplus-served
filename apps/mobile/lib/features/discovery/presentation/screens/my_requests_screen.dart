import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_design_system/ss_design_system.dart';

import '../../../../shared/utils/status_mapper.dart';
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
    final donationsAsync = ref.watch(receiverDonationsProvider);

    return RoleScaffold(
      currentIndex: 1,
      tabs: receiverTabs,
      appBarTitle: 'Your requests',
      body: donationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Something went wrong: $err')),
        data: (allDonations) {
          final active = allDonations
              .where((d) => d.status == DonationStatus.allocated || d.status == DonationStatus.reallocated)
              .toList();
          if (active.isEmpty) {
            return Center(
              child: SsEmptyState(
                title: 'No active requests',
                message: 'Request a donation from the feed and it will show up here once matched.',
                illustration: SsIllustrations.noRequestsYet,
                primaryActionLabel: 'Browse nearby surplus',
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
                subtitle: 'From ${d.donorName} · ${d.portions} portions',
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
