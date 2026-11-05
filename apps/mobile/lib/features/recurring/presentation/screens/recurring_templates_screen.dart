import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_design_system/ss_design_system.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/providers.dart';
import '../../../../shared/utils/food_labels.dart';
import '../../../../shared/widgets/async_error_view.dart';
import '../../../../shared/widgets/role_scaffold.dart';
import '../../../../shared/widgets/role_tabs.dart';
import '../../../../shared/widgets/text_input_dialog.dart';
import '../../../donation/presentation/controllers/donation_providers.dart';
import '../../domain/recurring_template.dart';
import '../controllers/recurring_providers.dart';
import 'create_recurring_template_sheet.dart';

/// Recurring donations: standing templates a donor confirms or skips each
/// day, rather than filling out the full donation form every time.
class RecurringTemplatesScreen extends ConsumerWidget {
  const RecurringTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final templatesAsync = ref.watch(recurringTemplatesProvider);

    return RoleScaffold(
      currentIndex: 1,
      tabs: donorTabs(l10n),
      appBarTitle: l10n.recurringTitle,
      floatingActionButton: FloatingActionButton(
        key: const Key('addRecurringButton'),
        onPressed: () => showCreateRecurringTemplateSheet(context, ref),
        child: SsIcon(SsIcons.plus, color: context.ssColors.onPrimary),
      ),
      body: templatesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => AsyncErrorView(
          error: err,
          onRetry: () => ref.invalidate(recurringTemplatesProvider),
        ),
        data: (templates) {
          if (templates.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => ref.refresh(recurringTemplatesProvider.future),
              child: ListView(
                children: [
                  const SizedBox(height: SsSpacing.xxl),
                  SsEmptyState(
                    title: l10n.recurringEmptyTitle,
                    message: l10n.recurringEmptyMessage,
                    illustration: SsIllustrations.nothingHereYet,
                    primaryActionLabel: l10n.recurringSetupCta,
                    onPrimaryAction: () =>
                        showCreateRecurringTemplateSheet(context, ref),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(recurringTemplatesProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                SsSpacing.lg,
                SsSpacing.lg,
                SsSpacing.lg,
                96, // room for the add button
              ),
              itemCount: templates.length,
              separatorBuilder: (_, _) => const SizedBox(height: SsSpacing.md),
              itemBuilder: (context, i) =>
                  _TemplateCard(template: templates[i]),
            ),
          );
        },
      ),
    );
  }
}

class _TemplateCard extends ConsumerStatefulWidget {
  const _TemplateCard({required this.template});

  final RecurringTemplate template;

  @override
  ConsumerState<_TemplateCard> createState() => _TemplateCardState();
}

class _TemplateCardState extends ConsumerState<_TemplateCard> {
  bool _busy = false;

  RecurringTemplate get t => widget.template;

  Future<void> _run(
    Future<void> Function() action, {
    String? success,
    bool postedDonation = false,
  }) async {
    if (_busy) return;
    setState(() => _busy = true);

    try {
      await action();
      if (!mounted) return;
      if (success != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(success)));
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
      ref.invalidate(recurringTemplatesProvider);
      // A confirmed template is a new live donation on the dashboard.
      if (postedDonation) ref.invalidate(donorDonationsProvider);
    }
  }

  Future<void> _confirm() async {
    final text = await showTextInputDialog(
      context,
      title: "Post today's donation?",
      confirmLabel: 'Post now',
      label: 'Portions today',
      helperText: 'Pickup window: next ${t.windowHours} hour(s)',
      initialText: '${t.portions}',
      keyboardType: TextInputType.number,
      validator: (v) {
        final n = int.tryParse(v.trim());
        if (n == null || n < 1 || n > 1000) {
          return 'Enter a number from 1 to 1000.';
        }
        return null;
      },
    );

    if (text == null || !mounted) return;

    final portions = int.parse(text.trim());
    await _run(
      () => ref
          .read(recurringRepositoryProvider)
          .confirmToday(t.id, portions: portions),
      success: "Today's donation is live. NGOs can now request it.",
      postedDonation: true,
    );
  }

  Future<void> _delete() async {
    final ok = await SsDialog.confirm(
      context,
      title: 'Delete recurring donation?',
      message: 'Donations you already posted from it are not affected.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (ok != true || !mounted) return;

    await _run(
      () => ref.read(recurringRepositoryProvider).deleteTemplate(t.id),
      success: 'Recurring donation deleted.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;
    final l10n = AppLocalizations.of(context)!;
    final diet = FoodLabels.diet(t.dietType);

    return Container(
      padding: const EdgeInsets.all(SsSpacing.lg),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.border),
        borderRadius: BorderRadius.circular(SsRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  t.title,
                  style: SsTypeScale.h4.copyWith(color: c.onSurface),
                ),
              ),
              if (!t.active)
                const SsTag(label: 'Paused', tone: SsTagTone.neutral)
              else if (t.confirmedToday)
                SsTag(
                  label: l10n.recurringPostedTodayTag,
                  icon: SsIcons.check,
                  tone: SsTagTone.positive,
                )
              else if (t.skippedToday)
                SsTag(
                  label: l10n.recurringSkippedTodayTag,
                  tone: SsTagTone.neutral,
                ),
              PopupMenuButton<String>(
                key: Key('recurringMenu-${t.id}'),
                enabled: !_busy,
                onSelected: (value) => switch (value) {
                  'pause' => _run(
                      () => ref
                          .read(recurringRepositoryProvider)
                          .setActive(t.id, false),
                      success: 'Paused. It stays off until you resume it.',
                    ),
                  'resume' => _run(
                      () => ref
                          .read(recurringRepositoryProvider)
                          .setActive(t.id, true),
                      success: 'Resumed.',
                    ),
                  _ => _delete(),
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: t.active ? 'pause' : 'resume',
                    child: Text(t.active ? 'Pause' : 'Resume'),
                  ),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.recurringCardSubtitle(t.portions, t.windowHours, t.locality),
            style: SsTypeScale.small.copyWith(color: c.onSurfaceVariant),
          ),
          const SizedBox(height: 2),
          Text(
            [
              FoodLabels.category(t.foodCategory),
              ?diet,
              'Safe for ${t.safeHours} h',
            ].join(' · '),
            style: SsTypeScale.small.copyWith(color: c.onSurfaceVariant),
          ),
          if (t.needsTodayDecision) ...[
            const SizedBox(height: SsSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: SsButton.secondary(
                    label: l10n.recurringSkipCta,
                    onPressed: _busy
                        ? null
                        : () => _run(
                              () => ref
                                  .read(recurringRepositoryProvider)
                                  .skipToday(t.id),
                              success: 'Skipped for today.',
                            ),
                  ),
                ),
                const SizedBox(width: SsSpacing.md),
                Expanded(
                  child: SsButton.primary(
                    label: l10n.recurringConfirmCta,
                    isLoading: _busy,
                    onPressed: _busy ? null : _confirm,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
