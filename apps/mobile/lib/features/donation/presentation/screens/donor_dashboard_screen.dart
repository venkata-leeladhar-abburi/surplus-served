import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_design_system/ss_design_system.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/providers.dart';
import '../../../../shared/utils/status_mapper.dart';
import '../../../../shared/widgets/async_error_view.dart';
import '../../../../shared/widgets/role_scaffold.dart';
import '../../../../shared/widgets/role_tabs.dart';
import '../../domain/donation.dart';
import '../controllers/donation_providers.dart';

class DonorDashboardScreen extends ConsumerWidget {
  const DonorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.ssColors;
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(sessionProvider);
    final donationsAsync = ref.watch(donorDonationsProvider);

    return RoleScaffold(
      currentIndex: 0,
      tabs: donorTabs(l10n),
      appBarTitle: l10n.donorDashboardTitle,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed('donorCreate'),
        icon: SsIcon(SsIcons.addFood, color: c.onPrimary),
        label: Text(l10n.donorCreateCta, style: TextStyle(color: c.onPrimary)),
        backgroundColor: c.primary,
      ),
      body: donationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => AsyncErrorView(
          error: err,
          onRetry: () => ref.invalidate(donorDonationsProvider),
        ),
        data: (allDonations) {
          // Terminal donations (collected, cancelled, ...) live in History —
          // this tab is "what's still in flight".
          final donations = allDonations
              .where((d) => d.status.isActive)
              .toList();
          if (donations.isEmpty) {
            return Center(
              child: SsEmptyState(
                title: l10n.donorDashboardEmptyTitle,
                message: session == null
                    ? ''
                    : l10n.donorDashboardEmptyMessage(
                        session.name.split(' ').first,
                      ),
                illustration: SsIllustrations.nothingHereYet,
                primaryActionLabel: l10n.donorCreateCta,
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
    final l10n = AppLocalizations.of(context)!;
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
                    Text(
                      donation.title,
                      style: SsTypeScale.h4.copyWith(color: c.onSurface),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.commonPortionsLabel(donation.portions),
                      style: SsTypeScale.small.copyWith(
                        color: c.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              SsStatusBadge(
                status: donation.status.ssStatus,
                label: donation.status.label(l10n),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
