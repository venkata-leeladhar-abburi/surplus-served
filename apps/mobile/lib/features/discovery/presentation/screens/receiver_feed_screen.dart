import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_design_system/ss_design_system.dart';

import '../../../../shared/utils/status_mapper.dart';
import '../../../../shared/widgets/role_scaffold.dart';
import '../../../../shared/widgets/role_tabs.dart';
import '../../../donation/domain/donation.dart';
import '../controllers/discovery_providers.dart';

class ReceiverFeedScreen extends ConsumerWidget {
  const ReceiverFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(receiverFeedProvider);

    return RoleScaffold(
      currentIndex: 0,
      tabs: receiverTabs,
      appBarTitle: 'Nearby surplus',
      body: feedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Something went wrong: $err')),
        data: (donations) {
          if (donations.isEmpty) {
            return Center(
              child: SsEmptyState(
                title: 'Nothing here yet',
                message: 'New donations nearby will show up here the moment they go live.',
                illustration: SsIllustrations.noFoodAvailable,
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(SsSpacing.lg),
            itemCount: donations.length,
            separatorBuilder: (_, _) => const SizedBox(height: SsSpacing.md),
            itemBuilder: (context, i) {
              final d = donations[i];
              return SsDonationCard(
                title: d.title,
                donorName: d.donorName,
                imageUrl: null,
                status: d.status.ssStatus,
                servingsLabel: '${d.portions} portions',
                timeLeftLabel: _timeLeftLabel(d),
                distanceLabel: d.address.locality,
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

  String _timeLeftLabel(Donation d) {
    final minutes = d.minutesRemaining(DateTime.now());
    return minutes >= 60 ? '${(minutes / 60).floor()} hr left' : '$minutes min left';
  }
}
