
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
import '../../../../shared/widgets/donation_food_details.dart';
import '../../domain/donation_status.dart';
import '../controllers/donation_providers.dart';
import '../widgets/donor_requests_section.dart';

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
  bool _cancelling = false;

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
                      DonationFoodDetails(donation: donation),
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
                        donation.status == DonationStatus.live &&
                                donation.remainingPortions != null &&
                                donation.remainingPortions !=
                                    donation.portions
                            ? '${donation.remainingPortions} of '
                                '${donation.portions} portions still available'
                            : l10n.commonPortionsLabel(donation.portions),
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
                      ],

                      // NGO requests: approve/reject, pickup verification
                      // and request history for this donation.
                      if (donation.status == DonationStatus.live ||
                          donation.status == DonationStatus.allocated ||
                          donation.status == DonationStatus.collected) ...[
                        const SizedBox(height: SsSpacing.lg),
                        DonorRequestsSection(donationId: donation.id),
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
                          isLoading: _cancelling,
                          onPressed: _cancelling
                              ? null
                              : () => _cancelDonation(donation.id),
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

  Future<void> _cancelDonation(String donationId) async {
    if (_cancelling) return;

    final confirmed = await SsDialog.confirm(
      context,
      title: 'Cancel donation?',
      message: 'NGOs will no longer be able to request this donation.',
      confirmLabel: 'Cancel donation',
      cancelLabel: 'Keep it',
      destructive: true,
    );

    if (confirmed != true || !mounted) return;

    setState(() => _cancelling = true);

    try {
      final session = ref.read(sessionProvider);

      await ref
          .read(donationRepositoryProvider)
          .cancel(donationId, authToken: session?.token);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Donation cancelled.')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error
                .toString()
                .replaceAll('Exception: ', '')
                .replaceFirst('Network error cancelling donation: ', ''),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _cancelling = false);
        ref.invalidate(donationByIdProvider(donationId));
        ref.invalidate(donorDonationsProvider);
        ref.invalidate(donorAllocationsProvider);
      }
    }
  }
}
