
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
import '../../../../shared/widgets/text_input_dialog.dart';
import '../../../donation/domain/donation_status.dart';
import '../../../donation/presentation/controllers/donation_providers.dart';
import '../controllers/discovery_providers.dart';
import '../controllers/receiver_donations_providers.dart';

class DonationDetailScreen extends ConsumerStatefulWidget {
  const DonationDetailScreen({super.key, required this.donationId});

  final String donationId;

  @override
  ConsumerState<DonationDetailScreen> createState() =>
      _DonationDetailScreenState();
}

class _DonationDetailScreenState extends ConsumerState<DonationDetailScreen> {
  bool _requesting = false;

  Future<void> _request(int availablePortions) async {
    final session = ref.read(sessionProvider);

    if (session == null || session.token == null || session.token!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in again.')),
      );
      return;
    }

    if (availablePortions <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No portions are currently available.')),
      );
      return;
    }

    final requestedPortions = await _askPortions(availablePortions);

    if (requestedPortions == null || !mounted) return;

    setState(() => _requesting = true);

    try {
      await ref.read(allocationRepositoryProvider).requestDonation(
            donationId: widget.donationId,
            ngoId: session.userId,
            ngoName: session.name,
            requestedPortions: requestedPortions,
          );

      if (!mounted) return;

      ref.invalidate(donationByIdProvider(widget.donationId));
      ref.invalidate(receiverAllocationsProvider);
      ref.invalidate(receiverFeedProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Donation request submitted successfully.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _requesting = false);
      }
    }
  }

  /// Asks how many portions to request (1 to [maxPortions]).
  /// Returns null if the NGO cancels.
  Future<int?> _askPortions(int maxPortions) async {
    final text = await showTextInputDialog(
      context,
      title: 'How many portions?',
      helperText: '$maxPortions portion(s) available',
      initialText: '$maxPortions',
      keyboardType: TextInputType.number,
      confirmLabel: 'Request',
      validator: (v) {
        final value = int.tryParse(v);
        return value == null || value < 1 || value > maxPortions
            ? 'Enter a number from 1 to $maxPortions.'
            : null;
      },
    );

    return text == null ? null : int.tryParse(text);
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
                final session = ref.watch(sessionProvider);

                final allocatedToMe =
                    donation.status == DonationStatus.allocated &&
                    donation.allocatedToNgoId == session?.userId;

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
                        l10n.receiverFromDonorLabel(donation.donorName),
                        style: SsTypeScale.body.copyWith(
                          color: c.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: SsSpacing.lg),
                      if (donation.description != null) ...[
                        Text(
                          donation.description!,
                          style: SsTypeScale.body.copyWith(
                            color: c.onSurface,
                          ),
                        ),
                        const SizedBox(height: SsSpacing.lg),
                      ],
                      Row(
                        children: [
                          SsTag(
                            label: l10n.commonPortionsLabel(
                              donation.remainingPortions ?? donation.portions,
                            ),
                            icon: SsIcons.meals,
                          ),
                          const SizedBox(width: SsSpacing.sm),
                          SsTag(
                            label: l10n.timeLeftMinutes(
                              donation.minutesRemaining(DateTime.now()),
                            ),
                            icon: SsIcons.time,
                            tone: SsTagTone.warm,
                          ),
                        ],
                      ),
                      const SizedBox(height: SsSpacing.xl),
                      if (donation.address.hasExactDetails && allocatedToMe)
                        SsLocationRow(
                          address: donation.address.exactLine!,
                          contactName: donation.address.contactName,
                          phone: donation.address.contactPhone,
                        )
                      else
                        SsLocationRow(
                          address: donation.address.locality,
                          locked: true,
                        ),
                      const SizedBox(height: SsSpacing.xxl),
                      if (donation.status == DonationStatus.live)
                        SsButton.primary(
                          label: l10n.receiverRequestCta,
                          expand: true,
                          isLoading: _requesting,
                          onPressed: _requesting
                              ? null
                              : () => _request(
                                    donation.remainingPortions ??
                                        donation.portions,
                                  ),
                        ),
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
}
