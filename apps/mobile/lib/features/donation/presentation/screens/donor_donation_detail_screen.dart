
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_design_system/ss_design_system.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/providers.dart';
import '../../../../shared/utils/status_mapper.dart';
import '../../../../shared/widgets/async_error_view.dart';
import '../../../../shared/widgets/connectivity_banner.dart';
import '../../../allocation/domain/allocation.dart';
import '../../domain/donation_status.dart';
import '../controllers/donation_providers.dart';

class DonorDonationDetailScreen extends ConsumerStatefulWidget {
  const DonorDonationDetailScreen({super.key, required this.donationId});

  final String donationId;

  @override
  ConsumerState<DonorDonationDetailScreen> createState() =>
      _DonorDonationDetailScreenState();
}

class _DonorDonationDetailScreenState
    extends ConsumerState<DonorDonationDetailScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(
      const Duration(seconds: 30),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;
    final l10n = AppLocalizations.of(context)!;
    final donationAsync = ref.watch(donationByIdProvider(widget.donationId));

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        elevation: 0,
        leading: IconButton(
          icon: SsIcon(SsIcons.arrowLeft, color: c.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          const ConnectivityBanner(),
          Expanded(
            child: donationAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (err, _) => AsyncErrorView(
                error: err,
                onRetry: () =>
                    ref.invalidate(donationByIdProvider(widget.donationId)),
              ),
              data: (donation) {
                final total = donation.pickupWindowEnd.difference(
                  donation.pickupWindowStart,
                );
                final remaining = Duration(
                  minutes: donation.minutesRemaining(DateTime.now()),
                );

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(SsSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              donation.title,
                              style: SsTypeScale.h3.copyWith(
                                color: c.onSurface,
                              ),
                            ),
                          ),
                          SsStatusBadge(
                            status: donation.status.ssStatus,
                            label: donation.status.label(l10n),
                          ),
                        ],
                      ),
                      const SizedBox(height: SsSpacing.sm),
                      Text(
                        l10n.commonPortionsLabel(donation.portions),
                        style: SsTypeScale.body.copyWith(
                          color: c.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: SsSpacing.xxl),

                      if (donation.status == DonationStatus.live) ...[
                        Center(
                          child: SsFreshnessRing(
                            remaining: remaining,
                            total: total,
                            size: 120,
                          ),
                        ),
                        const SizedBox(height: SsSpacing.lg),
                        SsAlert(message: l10n.donorLiveAlert),
                      ],

                      if (donation.status == DonationStatus.allocated) ...[
                        SsAlert(
                          tone: SsAlertTone.success,
                          message: l10n.donorAllocatedAlert(
                            donation.allocatedToNgoName ?? '',
                          ),
                        ),
                        const SizedBox(height: SsSpacing.lg),
                        _buildAllocationSection(),
                      ],

                      if (donation.status == DonationStatus.collected) ...[
                        Center(
                          child: SsIllustration(
                            SsIllustrations.deliveryCompleted,
                            width: 160,
                          ),
                        ),
                        const SizedBox(height: SsSpacing.lg),
                        Center(
                          child: Text(
                            l10n.donorCollectedByLabel(
                              donation.allocatedToNgoName ?? '',
                            ),
                            style: SsTypeScale.h4.copyWith(
                              color: c.onSurface,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: SsSpacing.xxl),

                      if (donation.address.hasExactDetails) ...[
                        Text(
                          l10n.commonPickupAddressLabel,
                          style: SsTypeScale.small.copyWith(
                            color: c.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: SsSpacing.xs),
                        SsLocationRow(
                          address: donation.address.exactLine!,
                          contactName: donation.address.contactName,
                          phone: donation.address.contactPhone,
                        ),
                      ],

                      if (donation.status == DonationStatus.live) ...[
                        const SizedBox(height: SsSpacing.xxl),
                        SsButton.danger(
                          label: l10n.donorCancelCta,
                          expand: true,
                          onPressed: () => ref
                              .read(donationRepositoryProvider)
                              .cancel(donation.id),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllocationSection() {
    final c = context.ssColors;
    final allocationsAsync = ref.watch(donorAllocationsProvider);

    return allocationsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Could not load allocation details.'),
          TextButton(
            onPressed: () => ref.invalidate(donorAllocationsProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
      data: (allocations) {
        final matchingAllocations = allocations.where((allocation) {
          return allocation.donationId == widget.donationId &&
              allocation.isApproved;
        }).toList();

        if (matchingAllocations.isEmpty) {
          return const Text(
            'Your donation is allocated. Allocation details will appear here.',
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Pickup verification',
              style: SsTypeScale.h4.copyWith(color: c.onSurface),
            ),
            const SizedBox(height: SsSpacing.md),
            ...matchingAllocations.map(
              (allocation) => _buildAllocationCard(allocation),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAllocationCard(Allocation allocation) {
    final c = context.ssColors;

    return Card(
      color: c.surface,
      margin: const EdgeInsets.only(bottom: SsSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(SsSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              allocation.ngoName ?? 'NGO',
              style: SsTypeScale.h4.copyWith(color: c.onSurface),
            ),
            const SizedBox(height: SsSpacing.xs),
            Text(
              'Allocated portions: ${allocation.allocatedPortions}',
              style: SsTypeScale.body.copyWith(
                color: c.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: SsSpacing.md),
            ElevatedButton.icon(
              onPressed: () {
                context.push(
                  '/donor/donation/${widget.donationId}/allocation/${allocation.id}/verify-pickup',
                );
              },
              icon: const Icon(Icons.verified_outlined),
              label: const Text('Verify pickup'),
            ),
          ],
        ),
      ),
    );
  }
}
