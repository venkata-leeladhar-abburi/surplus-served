import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_design_system/ss_design_system.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/providers.dart';
import '../../../../shared/utils/status_mapper.dart';
import '../../../donation/domain/donation_status.dart';
import '../../../donation/presentation/controllers/donation_providers.dart';

/// The receiver's view of one live (or already-allocated) donation.
/// Requesting it drives the allocation path (scope §15): a synchronous call
/// in the fixture, a BullMQ job over Socket.IO in production — same shape
/// either way, since this screen only talks to `AllocationRepository`.
class DonationDetailScreen extends ConsumerStatefulWidget {
  const DonationDetailScreen({super.key, required this.donationId});

  final String donationId;

  @override
  ConsumerState<DonationDetailScreen> createState() => _DonationDetailScreenState();
}

class _DonationDetailScreenState extends ConsumerState<DonationDetailScreen> {
  bool _requesting = false;

  Future<void> _request() async {
    final session = ref.read(sessionProvider);
    if (session == null) return;
    setState(() => _requesting = true);
    try {
      await ref.read(allocationRepositoryProvider).requestDonation(
            donationId: widget.donationId,
            ngoId: session.userId,
            ngoName: session.name,
          );
    } finally {
      if (mounted) setState(() => _requesting = false);
    }
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
      body: donationAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text(l10n.commonError('$err'))),
        data: (donation) {
          final session = ref.watch(sessionProvider);
          final allocatedToMe = donation.status == DonationStatus.allocated &&
              donation.allocatedToNgoId == session?.userId;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(SsSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(donation.title, style: SsTypeScale.h3.copyWith(color: c.onSurface)),
                    ),
                    SsStatusBadge(status: donation.status.ssStatus, label: donation.status.label(l10n)),
                  ],
                ),
                const SizedBox(height: SsSpacing.sm),
                Text(l10n.receiverFromDonorLabel(donation.donorName),
                    style: SsTypeScale.body.copyWith(color: c.onSurfaceVariant)),
                const SizedBox(height: SsSpacing.lg),
                if (donation.description != null) ...[
                  Text(donation.description!, style: SsTypeScale.body.copyWith(color: c.onSurface)),
                  const SizedBox(height: SsSpacing.lg),
                ],
                Row(
                  children: [
                    SsTag(label: l10n.commonPortionsLabel(donation.portions), icon: SsIcons.meals),
                    const SizedBox(width: SsSpacing.sm),
                    SsTag(
                      label: l10n.timeLeftMinutes(donation.minutesRemaining(DateTime.now())),
                      icon: SsIcons.time,
                      tone: SsTagTone.warm,
                    ),
                  ],
                ),
                const SizedBox(height: SsSpacing.xl),
                // §11: exact address only appears once this NGO holds the
                // allocation — enforced upstream, the screen just renders
                // whatever the repository gives it.
                if (donation.address.hasExactDetails && allocatedToMe)
                  SsLocationRow(
                    address: donation.address.exactLine!,
                    contactName: donation.address.contactName,
                    phone: donation.address.contactPhone,
                  )
                else
                  SsLocationRow(address: donation.address.locality, locked: true),
                const SizedBox(height: SsSpacing.xxl),
                if (donation.status == DonationStatus.live)
                  SsButton.primary(
                    label: l10n.receiverRequestCta,
                    expand: true,
                    isLoading: _requesting,
                    onPressed: _requesting ? null : _request,
                  ),
                if (allocatedToMe)
                  SsButton.primary(
                    label: l10n.receiverEnterCodeCta,
                    expand: true,
                    onPressed: () => context.pushNamed(
                      'receiverEnterCode',
                      pathParameters: {'id': donation.id},
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
