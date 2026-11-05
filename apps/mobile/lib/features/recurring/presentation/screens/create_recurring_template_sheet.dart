import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_design_system/ss_design_system.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/providers.dart';
import '../../../../shared/utils/food_labels.dart';
import '../controllers/recurring_providers.dart';

Future<void> showCreateRecurringTemplateSheet(
  BuildContext context,
  WidgetRef ref,
) {
  final l10n = AppLocalizations.of(context)!;
  return SsSheet.show<void>(
    context,
    title: l10n.recurringSheetTitle,
    child: _CreateTemplateForm(ref: ref),
  );
}

class _CreateTemplateForm extends StatefulWidget {
  const _CreateTemplateForm({required this.ref});

  final WidgetRef ref;

  @override
  State<_CreateTemplateForm> createState() => _CreateTemplateFormState();
}

class _CreateTemplateFormState extends State<_CreateTemplateForm> {
  static const _safeHourOptions = [1, 2, 3, 4, 6, 8, 12, 24];

  final _titleController = TextEditingController();
  final _localityController = TextEditingController();
  int _portions = 20;
  int _windowHours = 2;
  int _safeHours = 4;
  String _category = 'cooked_meal';
  String? _diet;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _localityController.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _titleController.text.trim().isNotEmpty &&
      _localityController.text.trim().isNotEmpty;

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await widget.ref.read(recurringRepositoryProvider).createTemplate(
            title: _titleController.text.trim(),
            portions: _portions,
            windowHours: _windowHours,
            safeHours: _safeHours,
            locality: _localityController.text.trim(),
            foodCategory: _category,
            dietType: _diet,
          );
      widget.ref.invalidate(recurringTemplatesProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.ssColors;
    final safeOptions =
        _safeHourOptions.where((h) => h >= _windowHours).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SsSpacing.xl,
        0,
        SsSpacing.xl,
        SsSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SsTextField(
            key: const Key('recurringTitleField'),
            label: l10n.recurringFoodLabel,
            hint: l10n.recurringFoodHint,
            controller: _titleController,
            autofocus: true,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: SsSpacing.md),
          SsTextField(
            key: const Key('recurringLocalityField'),
            label: l10n.commonLocality,
            controller: _localityController,
            prefixIcon: SsIcons.location,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: SsSpacing.md),
          Wrap(
            spacing: SsSpacing.sm,
            runSpacing: SsSpacing.sm,
            children: [
              for (final entry in FoodLabels.categories.entries)
                ChoiceChip(
                  label: Text(entry.value),
                  selected: _category == entry.key,
                  onSelected: (_) => setState(() => _category = entry.key),
                ),
            ],
          ),
          const SizedBox(height: SsSpacing.sm),
          Wrap(
            spacing: SsSpacing.sm,
            children: [
              for (final entry in FoodLabels.diets.entries)
                ChoiceChip(
                  label: Text(entry.value),
                  selected: _diet == entry.key,
                  onSelected: (selected) =>
                      setState(() => _diet = selected ? entry.key : null),
                ),
            ],
          ),
          const SizedBox(height: SsSpacing.md),
          Row(
            children: [
              Expanded(
                child: SsDropdown<int>(
                  label: l10n.recurringPortionsLabel,
                  value: _portions,
                  items: const [5, 10, 20, 30, 40, 50, 75, 100],
                  labelBuilder: (v) => '$v',
                  onChanged: (v) => setState(() => _portions = v ?? _portions),
                ),
              ),
              const SizedBox(width: SsSpacing.md),
              Expanded(
                child: SsDropdown<int>(
                  label: l10n.recurringWindowLabel,
                  value: _windowHours,
                  items: const [1, 2, 3, 4, 6],
                  labelBuilder: (v) => l10n.recurringHoursShort(v),
                  onChanged: (v) => setState(() {
                    _windowHours = v ?? _windowHours;
                    // Food must stay safe for the whole pickup window.
                    if (_safeHours < _windowHours) _safeHours = _windowHours;
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: SsSpacing.md),
          SsDropdown<int>(
            label: 'Safe to eat for',
            value: safeOptions.contains(_safeHours)
                ? _safeHours
                : safeOptions.first,
            items: safeOptions,
            labelBuilder: (v) => l10n.recurringHoursShort(v),
            onChanged: (v) => setState(() => _safeHours = v ?? _safeHours),
          ),
          const SizedBox(height: SsSpacing.sm),
          Text(
            'Each day you tap Confirm, the donation goes live with the pickup '
            'window starting then.',
            style: SsTypeScale.small.copyWith(color: c.onSurfaceVariant),
          ),
          if (_error != null) ...[
            const SizedBox(height: SsSpacing.sm),
            Text(
              _error!,
              style: SsTypeScale.small.copyWith(color: c.error),
            ),
          ],
          const SizedBox(height: SsSpacing.xl),
          SsButton.primary(
            key: const Key('recurringSaveButton'),
            label: l10n.recurringSaveCta,
            expand: true,
            isLoading: _saving,
            onPressed: _canSave && !_saving ? _save : null,
          ),
        ],
      ),
    );
  }
}
