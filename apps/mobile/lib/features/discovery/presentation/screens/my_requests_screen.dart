import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_design_system/ss_design_system.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/providers.dart';
import '../../../../shared/utils/allocation_status_mapper.dart';
import '../../../../shared/widgets/async_error_view.dart';
import '../../../../shared/widgets/role_scaffold.dart';
import '../../../../shared/widgets/role_tabs.dart';
import '../controllers/receiver_donations_providers.dart';

/// The NGO's in-progress donation requests.
///
/// - queued: waiting in the donation's FIFO queue
/// - awaiting_ngo_confirmation: fewer portions are left than requested;
///   the NGO must accept or decline the reduced quantity
/// - pending_donor: waiting for the donor to approve
/// - approved: shows the 6-digit pickup code to give the donor
///
/// Finished requests are shown on the History tab.
class MyRequestsScreen extends ConsumerStatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  ConsumerState<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends ConsumerState<MyRequestsScreen> {
  /// Allocation currently being confirmed or declined.
  String? _busyAllocationId;

  Future<void> _respondToOffer(
    ReceiverAllocation item, {
    required bool accept,
  }) async {
    if (_busyAllocationId != null) return;

    final offered = item.allocation.offeredPortions ?? 0;

    final confirmed = await SsDialog.confirm(
      context,
      title: accept ? 'Accept $offered portion(s)?' : 'Decline offer?',
      message: accept
          ? 'Only $offered of the ${item.allocation.requestedPortions} '
              'portions you asked for are left. The donor will then be asked '
              'to approve.'
          : 'Your request will be closed and the next NGO in the queue '
              'will be considered.',
      confirmLabel: accept ? 'Accept' : 'Decline',
      destructive: !accept,
    );

    if (confirmed != true || !mounted) return;

    setState(() => _busyAllocationId = item.allocation.id);

    try {
      await ref.read(allocationRepositoryProvider).confirmOffer(
            allocationId: item.allocation.id,
            accept: accept,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            accept
                ? 'Offer accepted. Waiting for donor approval.'
                : 'Offer declined.',
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
      if (mounted) {
        setState(() => _busyAllocationId = null);
        ref.invalidate(receiverAllocationsProvider);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final allocationsAsync = ref.watch(receiverAllocationsProvider);

    return RoleScaffold(
      currentIndex: 1,
      tabs: receiverTabs(l10n),
      appBarTitle: l10n.receiverRequestsTitle,
      body: allocationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => AsyncErrorView(
          error: err,
          onRetry: () => ref.invalidate(receiverAllocationsProvider),
        ),
        data: (all) {
          final active = all
              .where((item) => AllocationStatusView.isActive(
                    item.allocation.status,
                  ))
              .toList();

          if (active.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => ref.refresh(receiverAllocationsProvider.future),
              child: ListView(
                children: [
                  const SizedBox(height: SsSpacing.xxl),
                  SsEmptyState(
                    title: l10n.receiverRequestsEmptyTitle,
                    message: l10n.receiverRequestsEmptyMessage,
                    illustration: SsIllustrations.noRequestsYet,
                    primaryActionLabel: l10n.receiverBrowseCta,
                    onPrimaryAction: () => context.goNamed('receiverFeed'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(receiverAllocationsProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.all(SsSpacing.lg),
              itemCount: active.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: SsSpacing.md),
              itemBuilder: (context, i) => _buildItem(active[i], l10n),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItem(ReceiverAllocation item, AppLocalizations l10n) {
    final donation = item.donation;
    final allocation = item.allocation;
    final status = allocation.status;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SsListTile(
          title: donation.title,
          subtitle: l10n.receiverRequestSubtitle(
            donation.donorName,
            donation.portions,
          ),
          trailing: SsStatusBadge(
            status: AllocationStatusView.ssStatus(status),
            label: AllocationStatusView.label(status),
            dense: true,
          ),
          onTap: () => context.pushNamed(
            'receiverDonationDetail',
            pathParameters: {'id': donation.id},
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: SsSpacing.lg,
            right: SsSpacing.lg,
            top: SsSpacing.sm,
          ),
          child: switch (status) {
            'approved' => _buildPickupCode(allocation.pickupCode),
            'awaiting_ngo_confirmation' => _buildOfferActions(item),
            'pending_donor' => _hint(
                'Waiting for the donor to approve your request for '
                '${allocation.offeredPortions ?? allocation.requestedPortions} '
                'portion(s).',
              ),
            _ => _hint(
                'You are in the queue for this donation. The donor will '
                'review requests in the order they arrived.',
              ),
          },
        ),
      ],
    );
  }

  Widget _hint(String text) {
    final c = context.ssColors;

    return Text(
      text,
      style: SsTypeScale.small.copyWith(color: c.onSurfaceVariant),
    );
  }

  Widget _buildOfferActions(ReceiverAllocation item) {
    final busy = _busyAllocationId == item.allocation.id;
    final anyBusy = _busyAllocationId != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _hint(
          'Only ${item.allocation.offeredPortions ?? 0} of the '
          '${item.allocation.requestedPortions} portions you requested are '
          'left. Accept the smaller amount?',
        ),
        const SizedBox(height: SsSpacing.sm),
        Row(
          children: [
            Expanded(
              child: SsButton.secondary(
                label: 'Decline',
                expand: true,
                onPressed: anyBusy
                    ? null
                    : () => _respondToOffer(item, accept: false),
              ),
            ),
            const SizedBox(width: SsSpacing.md),
            Expanded(
              child: SsButton.primary(
                label: 'Accept',
                expand: true,
                isLoading: busy,
                onPressed: anyBusy
                    ? null
                    : () => _respondToOffer(item, accept: true),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPickupCode(String? pickupCode) {
    final c = context.ssColors;

    if (pickupCode == null || pickupCode.isEmpty) {
      return _hint('Pickup code is not available yet.');
    }

    return Container(
      padding: const EdgeInsets.all(SsSpacing.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pickup verification code',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: c.onSurfaceVariant),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  pickupCode,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: c.onSurface,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Show this code to the donor when you collect the food.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: c.onSurfaceVariant),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Copy pickup code',
            icon: Icon(Icons.copy, color: c.onSurfaceVariant),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: pickupCode));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pickup code copied.')),
              );
            },
          ),
        ],
      ),
    );
  }
}
