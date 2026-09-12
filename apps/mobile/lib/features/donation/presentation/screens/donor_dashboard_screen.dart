import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_design_system/ss_design_system.dart';

import '../../../../core/providers.dart';
import '../../../../shared/utils/status_mapper.dart';
import '../../domain/donation.dart';
import '../controllers/donation_providers.dart';

class DonorDashboardScreen extends ConsumerWidget {
  const DonorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.ssColors;
    final session = ref.watch(sessionProvider);
    final donationsAsync = ref.watch(donorDonationsProvider);

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        elevation: 0,
        title: Text('Your donations', style: SsTypeScale.h4.copyWith(color: c.onSurface)),
        actions: [
          IconButton(
            icon: SsIcon(SsIcons.logout, color: c.onSurfaceVariant),
            tooltip: 'Sign out',
            onPressed: () => ref.read(sessionProvider.notifier).signOut(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed('donorCreate'),
        icon: SsIcon(SsIcons.addFood, color: c.onPrimary),
        label: Text('Post surplus food', style: TextStyle(color: c.onPrimary)),
        backgroundColor: c.primary,
      ),
      body: donationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Something went wrong: $err')),
        data: (donations) {
          if (donations.isEmpty) {
            return Center(
              child: SsEmptyState(
                title: 'Nothing posted yet',
                message: session == null
                    ? ''
                    : 'Hi ${session.name.split(' ').first} — post your first surplus batch and it goes live instantly.',
                illustration: SsIllustrations.nothingHereYet,
                primaryActionLabel: 'Post surplus food',
                onPrimaryAction: () => context.pushNamed('donorCreate'),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(SsSpacing.lg),
            itemCount: donations.length,
            separatorBuilder: (_, _) => const SizedBox(height: SsSpacing.md),
            itemBuilder: (context, i) => _DonationRow(donation: donations[i]),
          );
        },
      ),
    );
  }
}

class _DonationRow extends StatelessWidget {
  const _DonationRow({required this.donation});

  final Donation donation;

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;
    return Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(SsRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(SsRadius.lg),
        onTap: () => context.pushNamed(
          'donorDonationDetail',
          pathParameters: {'id': donation.id},
        ),
        child: Container(
          padding: const EdgeInsets.all(SsSpacing.lg),
          decoration: BoxDecoration(
            border: Border.all(color: c.border),
            borderRadius: BorderRadius.circular(SsRadius.lg),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(donation.title, style: SsTypeScale.h4.copyWith(color: c.onSurface)),
                    const SizedBox(height: 4),
                    Text('${donation.portions} portions',
                        style: SsTypeScale.small.copyWith(color: c.onSurfaceVariant)),
                  ],
                ),
              ),
              SsStatusBadge(status: donation.status.ssStatus),
            ],
          ),
        ),
      ),
    );
  }
}
