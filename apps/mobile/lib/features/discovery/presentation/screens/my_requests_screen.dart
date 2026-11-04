
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_design_system/ss_design_system.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../shared/utils/status_mapper.dart';
import '../../../../shared/widgets/async_error_view.dart';
import '../../../../shared/widgets/role_scaffold.dart';
import '../../../../shared/widgets/role_tabs.dart';
import '../controllers/receiver_donations_providers.dart';

/// Approved donations this NGO currently holds and awaits pickup for.
class MyRequestsScreen extends ConsumerWidget {
  const MyRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final allocationsAsync = ref.watch(receiverAllocationsProvider);
    final c = context.ssColors;

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
        data: (allocations) {
          if (allocations.isEmpty) {
            return Center(
              child: SsEmptyState(
                title: l10n.receiverRequestsEmptyTitle,
                message: l10n.receiverRequestsEmptyMessage,
                illustration: SsIllustrations.noRequestsYet,
                primaryActionLabel: l10n.receiverBrowseCta,
                onPrimaryAction: () => context.goNamed('receiverFeed'),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(SsSpacing.lg),
            itemCount: allocations.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: SsSpacing.md),
            itemBuilder: (context, i) {
              final item = allocations[i];
              final donation = item.donation;
              final allocation = item.allocation;
              final pickupCode = allocation.pickupCode;

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
                      status: donation.status.ssStatus,
                      label: donation.status.label(l10n),
                      dense: true,
                    ),
                    onTap: () => context.pushNamed(
                      'receiverDonationDetail',
                      pathParameters: {'id': donation.id},
                    ),
                  ),
                  if (pickupCode != null && pickupCode.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: SsSpacing.lg,
                        right: SsSpacing.lg,
                        top: SsSpacing.sm,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(SsSpacing.md),
                        decoration: BoxDecoration(
                          color: c.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: c.outlineVariant),
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
                                        ?.copyWith(
                                          color: c.onSurfaceVariant,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  SelectableText(
                                    pickupCode,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: c.onSurface,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 4,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Copy pickup code',
                              icon: Icon(
                                Icons.copy,
                                color: c.onSurfaceVariant,
                              ),
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: pickupCode),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Pickup code copied.'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(
                        left: SsSpacing.lg,
                        right: SsSpacing.lg,
                        top: SsSpacing.xs,
                      ),
                      child: Text(
                        'Pickup code is not available yet.',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: c.onSurfaceVariant),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
