import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_design_system/ss_design_system.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../shared/utils/status_mapper.dart';
import '../../../../shared/widgets/role_scaffold.dart';
import '../../../../shared/widgets/role_tabs.dart';
import '../../../donation/domain/donation.dart';
import '../controllers/discovery_providers.dart';

class ReceiverFeedScreen extends ConsumerWidget {
  const ReceiverFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final feedAsync = ref.watch(receiverFeedProvider);

    return RoleScaffold(
      currentIndex: 0,
      tabs: receiverTabs(l10n),
      appBarTitle: l10n.receiverFeedTitle,
      body: feedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text(l10n.commonError('$err'))),
        data: (donations) {
          if (donations.isEmpty) {
            return Center(
              child: SsEmptyState(
                title: l10n.receiverFeedEmptyTitle,
                message: l10n.receiverFeedEmptyBody,
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
                statusLabel: d.status.label(l10n),
                servingsLabel: l10n.commonPortionsLabel(d.portions),
                timeLeftLabel: _timeLeftLabel(d, l10n),
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

  String _timeLeftLabel(Donation d, AppLocalizations l10n) {
    final minutes = d.minutesRemaining(DateTime.now());
    return minutes >= 60 ? l10n.timeLeftHours((minutes / 60).floor()) : l10n.timeLeftMinutes(minutes);
  }
}
