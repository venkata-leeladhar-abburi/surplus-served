import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_design_system/ss_design_system.dart';

import '../../../../core/providers.dart';
import '../../../allocation/domain/allocation.dart';
import '../controllers/donation_providers.dart';
import 'pickup_details_dialog.dart';

/// Shows every NGO request for one donation and lets the donor act on it.
///
/// Backend statuses (see apps/backend/models/Allocation.js):
/// - queued / awaiting_ngo_confirmation: waiting, no donor action yet
/// - pending_donor: donor must approve or reject
/// - approved: donor verifies the NGO's 6-digit pickup code at handover
/// - collected / rejected / declined / expired / cancelled: finished
class DonorRequestsSection extends ConsumerStatefulWidget {
  const DonorRequestsSection({super.key, required this.donationId});

  final String donationId;

  @override
  ConsumerState<DonorRequestsSection> createState() =>
      _DonorRequestsSectionState();
}

class _DonorRequestsSectionState extends ConsumerState<DonorRequestsSection> {
  /// Allocation ID currently being approved or rejected, to show a spinner
  /// and stop double taps.
  String? _busyAllocationId;

  void _refreshAll() {
    ref.invalidate(donorAllocationsProvider);
    ref.invalidate(donationByIdProvider(widget.donationId));
    ref.invalidate(donorDonationsProvider);
  }

  Future<void> _decide(Allocation allocation, {required bool approve}) async {
    if (_busyAllocationId != null) return;

    final ngoName = allocation.ngoName ?? 'this NGO';
    final portions = allocation.offeredPortions ?? allocation.requestedPortions;

    PickupDetails? details;

    if (approve) {
      // The donor shares the full address and phone with this NGO only.
      details = await showPickupDetailsDialog(
        context,
        ngoName: ngoName,
        portions: portions,
        getLocation: ref.read(pickupLocationFetcherProvider),
        initial: _lastPickupDetails(),
      );

      if (details == null || !mounted) return;
    } else {
      final confirmed = await SsDialog.confirm(
        context,
        title: 'Reject request?',
        message: 'The request from $ngoName will be rejected and the next '
            'NGO in the queue will be considered.',
        confirmLabel: 'Reject',
        destructive: true,
      );

      if (confirmed != true || !mounted) return;
    }

    setState(() => _busyAllocationId = allocation.id);

    try {
      final repository = ref.read(allocationRepositoryProvider);

      if (approve) {
        await repository.approveAllocation(
          allocationId: allocation.id,
          pickupAddress: details!.address,
          contactPhone: details.phone,
          contactName: details.contactName,
          pickupLatitude: details.latitude,
          pickupLongitude: details.longitude,
        );
      } else {
        await repository.rejectAllocation(allocationId: allocation.id);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            approve
                ? 'Request approved. $ngoName can now collect the food.'
                : 'Request rejected.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Always refresh: even on failure the server state may have moved on
      // (for example, the pickup window ended).
      if (mounted) {
        setState(() => _busyAllocationId = null);
        _refreshAll();
      }
    }
  }

  /// Pre-fills the approval form with the details from the donor's most
  /// recent approval, so they don't retype their address every time.
  PickupDetails? _lastPickupDetails() {
    final allocations = ref.read(donorAllocationsProvider).value ?? const [];

    for (final a in allocations) {
      final address = a.pickupAddress;
      final phone = a.contactPhone;
      if (address != null && address.isNotEmpty && phone != null) {
        return PickupDetails(
          address: address,
          phone: phone,
          contactName: a.contactName,
          latitude: a.pickupLatitude,
          longitude: a.pickupLongitude,
        );
      }
    }

    return null;
  }

  Future<void> _verifyPickup(Allocation allocation) async {
    final verified = await context.push<bool>(
      '/donor/donation/${widget.donationId}/allocation/${allocation.id}/verify-pickup',
    );

    if (!mounted || verified != true) return;

    _refreshAll();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pickup verified successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;
    final allocationsAsync = ref.watch(donorAllocationsProvider);

    return allocationsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(SsSpacing.lg),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Could not load NGO requests: '
            '${error.toString().replaceFirst('Exception: ', '')}',
          ),
          TextButton(
            onPressed: () => ref.invalidate(donorAllocationsProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
      data: (allocations) {
        final forThisDonation = allocations
            .where((a) => a.donationId == widget.donationId)
            .toList();

        final needsDecision =
            forThisDonation.where((a) => a.status == 'pending_donor').toList();
        final approved =
            forThisDonation.where((a) => a.status == 'approved').toList();
        final waiting = forThisDonation
            .where(
              (a) =>
                  a.status == 'queued' ||
                  a.status == 'awaiting_ngo_confirmation',
            )
            .toList();
        final finished = forThisDonation
            .where(
              (a) =>
                  !needsDecision.contains(a) &&
                  !approved.contains(a) &&
                  !waiting.contains(a),
            )
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'NGO requests',
                    style: SsTypeScale.h4.copyWith(color: c.onSurface),
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh',
                  icon: const Icon(Icons.refresh),
                  onPressed: _refreshAll,
                ),
              ],
            ),
            const SizedBox(height: SsSpacing.sm),
            if (forThisDonation.isEmpty)
              Text(
                'No NGO has requested this donation yet.',
                style: SsTypeScale.body.copyWith(color: c.onSurfaceVariant),
              ),
            ...needsDecision.map(_buildDecisionCard),
            ...approved.map(_buildApprovedCard),
            ...waiting.map(
              (a) => _buildInfoCard(
                a,
                a.status == 'queued'
                    ? 'In queue. You will be asked to decide when it is '
                        'this NGO\'s turn.'
                    : 'Waiting for the NGO to accept a reduced quantity '
                        '(${a.offeredPortions ?? '-'} portions).',
              ),
            ),
            ...finished.map(
              (a) => _buildInfoCard(a, _finishedLabel(a)),
            ),
          ],
        );
      },
    );
  }

  String _finishedLabel(Allocation a) => switch (a.status) {
        'collected' => 'Collected (${a.allocatedPortions} portions).',
        'rejected' => 'You rejected this request.',
        'declined' => 'The NGO declined the reduced quantity.',
        'expired' => 'Expired before it could be completed.',
        'cancelled' => 'Cancelled.',
        _ => 'Status: ${a.status}',
      };

  Widget _cardShell({required List<Widget> children}) {
    final c = context.ssColors;

    return Card(
      color: c.surface,
      margin: const EdgeInsets.only(bottom: SsSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(SsSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }

  Widget _buildDecisionCard(Allocation allocation) {
    final c = context.ssColors;
    final busy = _busyAllocationId == allocation.id;
    final anyBusy = _busyAllocationId != null;
    final portions = allocation.offeredPortions ?? allocation.requestedPortions;

    return _cardShell(
      children: [
        Text(
          allocation.ngoName ?? 'NGO',
          style: SsTypeScale.h4.copyWith(color: c.onSurface),
        ),
        const SizedBox(height: SsSpacing.xs),
        Text(
          'Requested ${allocation.requestedPortions} portion(s). '
          'If approved they receive $portions.',
          style: SsTypeScale.body.copyWith(color: c.onSurfaceVariant),
        ),
        const SizedBox(height: SsSpacing.md),
        Row(
          children: [
            Expanded(
              child: SsButton.secondary(
                label: 'Reject',
                expand: true,
                onPressed:
                    anyBusy ? null : () => _decide(allocation, approve: false),
              ),
            ),
            const SizedBox(width: SsSpacing.md),
            Expanded(
              child: SsButton.primary(
                label: 'Approve',
                expand: true,
                isLoading: busy,
                onPressed:
                    anyBusy ? null : () => _decide(allocation, approve: true),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildApprovedCard(Allocation allocation) {
    final c = context.ssColors;

    return _cardShell(
      children: [
        Text(
          allocation.ngoName ?? 'NGO',
          style: SsTypeScale.h4.copyWith(color: c.onSurface),
        ),
        const SizedBox(height: SsSpacing.xs),
        Text(
          'Approved for ${allocation.allocatedPortions} portion(s). '
          'Ask the NGO for their 6-digit pickup code at handover.',
          style: SsTypeScale.body.copyWith(color: c.onSurfaceVariant),
        ),
        if (allocation.pickupAddress != null) ...[
          const SizedBox(height: SsSpacing.sm),
          Text(
            'Shared with NGO: ${allocation.pickupAddress}'
            '${allocation.contactPhone != null ? ' · ${allocation.contactPhone}' : ''}',
            style: SsTypeScale.small.copyWith(color: c.onSurfaceVariant),
          ),
        ],
        const SizedBox(height: SsSpacing.md),
        ElevatedButton.icon(
          onPressed: () => _verifyPickup(allocation),
          icon: const Icon(Icons.verified_outlined),
          label: const Text('Verify pickup'),
        ),
      ],
    );
  }

  Widget _buildInfoCard(Allocation allocation, String message) {
    final c = context.ssColors;

    return _cardShell(
      children: [
        Text(
          allocation.ngoName ?? 'NGO',
          style: SsTypeScale.h5.copyWith(color: c.onSurface),
        ),
        const SizedBox(height: SsSpacing.xs),
        Text(
          message,
          style: SsTypeScale.small.copyWith(color: c.onSurfaceVariant),
        ),
      ],
    );
  }
}
