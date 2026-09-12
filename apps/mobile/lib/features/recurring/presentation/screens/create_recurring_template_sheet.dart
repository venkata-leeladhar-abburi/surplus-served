import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_design_system/ss_design_system.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/providers.dart';

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
  final _titleController = TextEditingController();
  final _localityController = TextEditingController();
  int _portions = 20;
  int _windowHours = 2;
  bool _saving = false;

  bool get _canSave =>
      _titleController.text.trim().isNotEmpty &&
      _localityController.text.trim().isNotEmpty;

  Future<void> _save() async {
    final session = widget.ref.read(sessionProvider);
    if (session == null) return;
    setState(() => _saving = true);
    await widget.ref
        .read(recurringRepositoryProvider)
        .createTemplate(
          donorId: session.userId,
          donorName: session.name,
          title: _titleController.text.trim(),
          portions: _portions,
          windowHours: _windowHours,
          locality: _localityController.text.trim(),
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
            label: l10n.recurringFoodLabel,
            hint: l10n.recurringFoodHint,
            controller: _titleController,
            autofocus: true,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: SsSpacing.md),
          SsTextField(
            label: l10n.commonLocality,
            controller: _localityController,
            prefixIcon: SsIcons.location,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: SsSpacing.md),
          Row(
            children: [
              Expanded(
                child: SsDropdown<int>(
                  label: l10n.recurringPortionsLabel,
                  value: _portions,
                  items: const [10, 20, 30, 40, 50],
                  labelBuilder: (v) => '$v',
                  onChanged: (v) => setState(() => _portions = v ?? _portions),
                ),
              ),
              const SizedBox(width: SsSpacing.md),
              Expanded(
                child: SsDropdown<int>(
                  label: l10n.recurringWindowLabel,
                  value: _windowHours,
                  items: const [1, 2, 3, 4],
                  labelBuilder: (v) => l10n.recurringHoursShort(v),
                  onChanged: (v) =>
                      setState(() => _windowHours = v ?? _windowHours),
                ),
              ),
            ],
          ),
          const SizedBox(height: SsSpacing.xl),
          SsButton.primary(
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
