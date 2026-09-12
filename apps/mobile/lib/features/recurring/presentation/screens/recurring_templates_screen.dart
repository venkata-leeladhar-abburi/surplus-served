import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_design_system/ss_design_system.dart';

import '../../../../core/providers.dart';
import '../../../../shared/widgets/role_scaffold.dart';
import '../../../../shared/widgets/role_tabs.dart';
import '../../domain/recurring_template.dart';
import '../controllers/recurring_providers.dart';
import 'create_recurring_template_sheet.dart';

/// §16 "recurring donations": standing templates a donor confirms or skips
/// each day, rather than filling out the full stepper every time.
class RecurringTemplatesScreen extends ConsumerWidget {
  const RecurringTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(recurringTemplatesProvider);

    return RoleScaffold(
      currentIndex: 1,
      tabs: donorTabs,
      appBarTitle: 'Recurring donations',
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCreateRecurringTemplateSheet(context, ref),
        child: SsIcon(SsIcons.plus, color: context.ssColors.onPrimary),
      ),
      body: templatesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Something went wrong: $err')),
        data: (templates) {
          if (templates.isEmpty) {
            return Center(
              child: SsEmptyState(
                title: 'No recurring donations yet',
                message: 'Set up a template for food you give away on a regular '
                    "schedule — we'll ask you to confirm or skip each day.",
                illustration: SsIllustrations.nothingHereYet,
                primaryActionLabel: 'Set up a template',
                onPrimaryAction: () => showCreateRecurringTemplateSheet(context, ref),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(SsSpacing.lg),
            itemCount: templates.length,
            separatorBuilder: (_, _) => const SizedBox(height: SsSpacing.md),
            itemBuilder: (context, i) => _TemplateCard(template: templates[i]),
          );
        },
      ),
    );
  }
}

class _TemplateCard extends ConsumerWidget {
  const _TemplateCard({required this.template});

  final RecurringTemplate template;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.ssColors;
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
                child: Text(template.title, style: SsTypeScale.h4.copyWith(color: c.onSurface)),
              ),
              if (template.confirmedToday)
                SsTag(label: 'Posted today', icon: SsIcons.check, tone: SsTagTone.positive)
              else if (template.skippedToday)
                SsTag(label: 'Skipped today', tone: SsTagTone.neutral),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${template.portions} portions · ${template.windowHours} hr window · ${template.locality}',
            style: SsTypeScale.small.copyWith(color: c.onSurfaceVariant),
          ),
          if (template.needsTodayDecision) ...[
            const SizedBox(height: SsSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: SsButton.secondary(
                    label: 'Skip today',
                    onPressed: () => ref.read(recurringRepositoryProvider).skipToday(template.id),
                  ),
                ),
                const SizedBox(width: SsSpacing.md),
                Expanded(
                  child: SsButton.primary(
                    label: 'Confirm today',
                    onPressed: () => ref.read(recurringRepositoryProvider).confirmToday(template.id),
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
