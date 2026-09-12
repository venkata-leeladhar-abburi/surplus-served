import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_design_system/ss_design_system.dart';

import '../../../../core/providers.dart';
import '../../../../shared/utils/status_mapper.dart';
import '../../../donation/domain/donation.dart';
import '../controllers/discovery_providers.dart';

class ReceiverFeedScreen extends ConsumerWidget {
  const ReceiverFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.ssColors;
    final feedAsync = ref.watch(receiverFeedProvider);

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        elevation: 0,
        title: Text('Nearby surplus', style: SsTypeScale.h4.copyWith(color: c.onSurface)),
        actions: [
          IconButton(
            icon: SsIcon(SsIcons.logout, color: c.onSurfaceVariant),
            tooltip: 'Sign out',
            onPressed: () => ref.read(sessionProvider.notifier).signOut(),
          ),
        ],
      ),
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
