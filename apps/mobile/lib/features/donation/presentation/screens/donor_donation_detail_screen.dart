import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_design_system/ss_design_system.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/providers.dart';
import '../../../../shared/utils/status_mapper.dart';
import '../../domain/donation_status.dart';
import '../controllers/donation_providers.dart';

/// The donor's view of one donation as it moves through its lifecycle —
/// the other end of the vertical slice from `DonationDetailScreen`
/// (receiver). Both watch the same `donationByIdProvider`, so a request or
/// a code entry on the receiver's side appears here without a refresh.
class DonorDonationDetailScreen extends ConsumerStatefulWidget {
  const DonorDonationDetailScreen({super.key, required this.donationId});

  final String donationId;

  @override
  ConsumerState<DonorDonationDetailScreen> createState() => _DonorDonationDetailScreenState();
}

class _DonorDonationDetailScreenState extends ConsumerState<DonorDonationDetailScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // The freshness ring reads wall-clock time, not just donation state, so
    // it has to repaint on its own even while nothing else changes.
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) => setState(() {}));
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
      body: donationAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text(l10n.commonError('$err'))),
        data: (donation) {
          final total = donation.pickupWindowEnd.difference(donation.pickupWindowStart);
          final remaining = Duration(minutes: donation.minutesRemaining(DateTime.now()));

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
                Text(l10n.commonPortionsLabel(donation.portions),
                    style: SsTypeScale.body.copyWith(color: c.onSurfaceVariant)),
                const SizedBox(height: SsSpacing.xxl),
                if (donation.status == DonationStatus.live) ...[
                  Center(child: SsFreshnessRing(remaining: remaining, total: total, size: 120)),
                  const SizedBox(height: SsSpacing.lg),
                  SsAlert(message: l10n.donorLiveAlert),
                ],
                if (donation.status == DonationStatus.allocated) ...[
                  SsAlert(
                    tone: SsAlertTone.success,
                    message: l10n.donorAllocatedAlert(donation.allocatedToNgoName ?? ''),
                  ),
                  const SizedBox(height: SsSpacing.xxl),
                  Center(
                    child: SsPickupCode(
                      code: donation.pickupCode!,
                      caption: l10n.donorPickupCodeCaption,
                    ),
                  ),
                ],
                if (donation.status == DonationStatus.collected) ...[
                  Center(child: SsIllustration(SsIllustrations.deliveryCompleted, width: 160)),
                  const SizedBox(height: SsSpacing.lg),
                  Center(
                    child: Text(l10n.donorCollectedByLabel(donation.allocatedToNgoName ?? ''),
                        style: SsTypeScale.h4.copyWith(color: c.onSurface)),
                  ),
                ],
                const SizedBox(height: SsSpacing.xxl),
                if (donation.address.hasExactDetails) ...[
                  Text(l10n.commonPickupAddressLabel,
                      style: SsTypeScale.small.copyWith(color: c.onSurfaceVariant)),
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
                    onPressed: () => ref.read(donationRepositoryProvider).cancel(donation.id),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
