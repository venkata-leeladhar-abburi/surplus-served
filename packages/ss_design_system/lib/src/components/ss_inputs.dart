import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../icons/ss_icon.dart';
import '../icons/ss_icons.g.dart';
import '../theme/ss_colors.dart';
import '../tokens/tokens.g.dart';
import 'ss_button.dart';

/// §06.2 Input field — default, focused, error and disabled states.
///
/// Wraps [TextFormField] so that the label, helper and error text are always
/// rendered in the same place, and the error is announced rather than only
/// coloured (§10 — meaning is never conveyed by colour alone).
class SsTextField extends StatelessWidget {
  const SsTextField({
    super.key,
    this.label,
    this.hint,
    this.helper,
    this.errorText,
    this.controller,
    this.initialValue,
    this.prefixIcon,
    this.suffix,
    this.keyboardType,
    this.inputFormatters,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.autofocus = false,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
  });

  final String? label;
  final String? hint;

  /// Guidance shown while the field is valid — "We'll only use this to contact
  /// you about a pickup."
  final String? helper;

  final String? errorText;
  final TextEditingController? controller;
  final String? initialValue;
  final SsIconData? prefixIcon;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final int? maxLength;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: SsTypeScale.small.copyWith(
              color: enabled ? c.onSurfaceVariant : c.muted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: SsSpacing.sm),
        ],
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          enabled: enabled,
          readOnly: readOnly,
          obscureText: obscureText,
          maxLines: obscureText ? 1 : maxLines,
          maxLength: maxLength,
          autofocus: autofocus,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textInputAction: textInputAction,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          onTap: onTap,
          validator: validator,
          style: SsTypeScale.body.copyWith(color: enabled ? c.onSurface : c.muted),
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
            // The message lives below, so the field itself only carries the
            // red border — this keeps the error text a single announcement.
            errorText: null,
            error: hasError ? const SizedBox.shrink() : null,
            prefixIcon: prefixIcon == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(
                      left: SsSpacing.lg,
                      right: SsSpacing.md,
                    ),
                    child: SsIcon(prefixIcon!, size: SsIconSize.md),
                  ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIcon: suffix,
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: SsSpacing.xs + 2),
          Semantics(
            liveRegion: true,
            child: Row(
              children: [
                SsIcon(SsIcons.alert, size: SsIconSize.xs, color: c.error),
                const SizedBox(width: SsSpacing.xs + 2),
                Expanded(
                  child: Text(
                    errorText!,
                    style: SsTypeScale.caption.copyWith(color: c.error),
                  ),
                ),
              ],
            ),
          ),
        ] else if (helper != null) ...[
          const SizedBox(height: SsSpacing.xs + 2),
          Text(helper!, style: SsTypeScale.caption.copyWith(color: c.onSurfaceVariant)),
        ],
      ],
    );
  }
}

/// §07.3 Search field, with an optional filter button beside it.
class SsSearchField extends StatelessWidget {
  const SsSearchField({
    super.key,
    this.hint = 'Search food, locations, or organizations…',
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onFilterTap,
    this.activeFilterCount = 0,
    this.autofocus = false,
  });

  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFilterTap;

  /// Shown as a badge on the filter button — filters that are on must be
  /// visible without opening the sheet.
  final int activeFilterCount;

  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;

    return Row(
      children: [
        Expanded(
          child: SsTextField(
            hint: hint,
            controller: controller,
            autofocus: autofocus,
            prefixIcon: SsIcons.search,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.search,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
          ),
        ),
        if (onFilterTap != null) ...[
          const SizedBox(width: SsSpacing.md),
          Semantics(
            button: true,
            label: activeFilterCount > 0
                ? 'Filters, $activeFilterCount active'
                : 'Filters',
            child: ExcludeSemantics(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Material(
                    color: c.surface,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: c.border),
                      borderRadius: BorderRadius.circular(SsRadius.md),
                    ),
                    child: InkWell(
                      onTap: onFilterTap,
                      borderRadius: BorderRadius.circular(SsRadius.md),
                      child: SizedBox(
                        height: SsA11y.minTapTarget + 4,
                        width: SsA11y.minTapTarget + 4,
                        child: SsIcon(SsIcons.filter, color: c.onSurface),
                      ),
                    ),
                  ),
                  if (activeFilterCount > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        height: 20,
                        width: 20,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: c.accent,
                          shape: BoxShape.circle,
                          border: Border.all(color: c.surface, width: 2),
                        ),
                        child: Text(
                          '$activeFilterCount',
                          style: SsTypeScale.caption.copyWith(
                            color: c.onAccent,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// §07.3 Filter chip row — "All · Food Type · Distance · Availability".
class SsFilterChips<T> extends StatelessWidget {
  const SsFilterChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.labelBuilder,
    this.multiSelect = false,
  });

  final List<T> options;
  final Set<T> selected;
  final ValueChanged<Set<T>> onChanged;
  final String Function(T)? labelBuilder;
  final bool multiSelect;

  String _label(T v) => labelBuilder?.call(v) ?? v.toString();

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: SsSpacing.screenPadding),
      child: Row(
        children: [
          for (final option in options) ...[
            Padding(
              padding: const EdgeInsets.only(right: SsSpacing.sm),
              child: FilterChip(
                label: Text(_label(option)),
                selected: selected.contains(option),
                onSelected: (isOn) {
                  if (multiSelect) {
                    final next = Set<T>.of(selected);
                    isOn ? next.add(option) : next.remove(option);
                    onChanged(next);
                  } else {
                    onChanged(isOn ? {option} : <T>{});
                  }
                },
                backgroundColor: c.surface,
                selectedColor: c.primary,
                side: BorderSide(
                  color: selected.contains(option) ? c.primary : c.border,
                ),
                labelStyle: SsTypeScale.small.copyWith(
                  color: selected.contains(option) ? c.onPrimary : c.onSurface,
                  fontWeight:
                      selected.contains(option) ? FontWeight.w600 : FontWeight.w400,
                ),
                showCheckmark: false,
                materialTapTargetSize: MaterialTapTargetSize.padded,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// §07.8 Date and time field. Tapping opens the platform picker; the field
/// itself is read-only so the value can never be half-typed.
class SsDateTimeField extends StatelessWidget {
  const SsDateTimeField({
    super.key,
    this.label,
    required this.value,
    required this.onChanged,
    this.mode = SsDateTimeMode.date,
    this.firstDate,
    this.lastDate,
    this.enabled = true,
    this.errorText,
  });

  final String? label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final SsDateTimeMode mode;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool enabled;
  final String? errorText;

  String _format(BuildContext context, DateTime v) {
    final l = MaterialLocalizations.of(context);
    return switch (mode) {
      SsDateTimeMode.date => l.formatMediumDate(v),
      SsDateTimeMode.time => l.formatTimeOfDay(TimeOfDay.fromDateTime(v)),
    };
  }

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    if (mode == SsDateTimeMode.date) {
      final picked = await showDatePicker(
        context: context,
        initialDate: value ?? now,
        firstDate: firstDate ?? now.subtract(const Duration(days: 1)),
        lastDate: lastDate ?? now.add(const Duration(days: 365)),
      );
      if (picked != null) onChanged(picked);
    } else {
      final picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(value ?? now),
      );
      if (picked != null) {
        final base = value ?? now;
        onChanged(DateTime(base.year, base.month, base.day, picked.hour, picked.minute));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SsTextField(
      label: label,
      readOnly: true,
      enabled: enabled,
      errorText: errorText,
      hint: mode == SsDateTimeMode.date ? 'Select a date' : 'Select a time',
      controller: TextEditingController(
        text: value == null ? '' : _format(context, value!),
      ),
      prefixIcon: mode == SsDateTimeMode.date ? SsIcons.calendar : SsIcons.time,
      suffix: Padding(
        padding: const EdgeInsets.only(right: SsSpacing.lg),
        child: SsIcon(
          SsIcons.chevronDown,
          size: SsIconSize.sm,
          color: enabled ? context.ssColors.onSurfaceVariant : context.ssColors.muted,
        ),
      ),
      onTap: enabled ? () => _pick(context) : null,
    );
  }
}

enum SsDateTimeMode { date, time }

/// §07.9 File upload — a drop zone plus thumbnails of what is already added.
///
/// Photos are required on every donation (scope §4.2), so this component
/// states the requirement rather than failing silently on submit.
class SsFileUpload extends StatelessWidget {
  const SsFileUpload({
    super.key,
    required this.onAdd,
    this.thumbnails = const [],
    this.onRemove,
    this.maxFiles = 5,
    this.hint = 'JPG, PNG up to 10MB',
    this.errorText,
  });

  final VoidCallback onAdd;

  /// Already-added images, as widgets so the caller controls the image source.
  final List<Widget> thumbnails;
  final ValueChanged<int>? onRemove;
  final int maxFiles;
  final String hint;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;
    final canAdd = thumbnails.length < maxFiles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (thumbnails.isEmpty)
          Semantics(
            button: true,
            label: 'Add photos. $hint',
            child: ExcludeSemantics(
              child: InkWell(
                onTap: onAdd,
                borderRadius: BorderRadius.circular(SsRadius.lg),
                child: DottedBorderBox(
                  color: errorText != null ? c.error : c.border,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: SsSpacing.xxl),
                    child: Column(
                      children: [
                        SsIcon(SsIcons.upload, size: SsIconSize.lg, color: c.primary),
                        const SizedBox(height: SsSpacing.md),
                        Text(
                          'Add photos',
                          style: SsTypeScale.body.copyWith(
                            color: c.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: SsSpacing.xs),
                        Text(hint, style: SsTypeScale.caption.copyWith(color: c.muted)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        else
          Wrap(
            spacing: SsSpacing.md,
            runSpacing: SsSpacing.md,
            children: [
              for (var i = 0; i < thumbnails.length; i++)
                SizedBox(
                  height: 84,
                  width: 84,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(SsRadius.md),
                          child: thumbnails[i],
                        ),
                      ),
                      if (onRemove != null)
                        Positioned(
                          top: -6,
                          right: -6,
                          child: SsIconButton(
                            icon: SsIcons.close,
                            tooltip: 'Remove photo ${i + 1}',
                            onPressed: () => onRemove!(i),
                          ),
                        ),
                    ],
                  ),
                ),
              if (canAdd)
                SizedBox(
                  height: 84,
                  width: 84,
                  child: Material(
                    color: c.surfaceAlt,
                    borderRadius: BorderRadius.circular(SsRadius.md),
                    child: InkWell(
                      onTap: onAdd,
                      borderRadius: BorderRadius.circular(SsRadius.md),
                      child: Semantics(
                        button: true,
                        label: 'Add another photo',
                        child: SsIcon(SsIcons.plus, color: c.primary),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        if (errorText != null) ...[
          const SizedBox(height: SsSpacing.sm),
          Semantics(
            liveRegion: true,
            child: Text(errorText!, style: SsTypeScale.caption.copyWith(color: c.error)),
          ),
        ],
      ],
    );
  }
}

/// A dashed outline, used by the upload drop zone. Flutter has no dashed
/// border, so it is painted.
class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox({super.key, required this.child, required this.color});

  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRectPainter(color: color, radius: SsRadius.lg),
      child: SizedBox(width: double.infinity, child: child),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  const _DashedRectPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    const dash = 6.0;
    const gap = 5.0;
    for (final metric in (Path()..addRRect(rrect)).computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRectPainter old) =>
      old.color != color || old.radius != radius;
}

/// A dropdown-style filter chip — "Food Type ⌄" — for the §07.3 filter row.
class SsFilterDropdownChip extends StatelessWidget {
  const SsFilterDropdownChip({
    super.key,
    required this.label,
    required this.onTap,
    this.value,
    this.active = false,
  });

  final String label;

  /// When set, the chip shows the chosen value instead of the field name and
  /// styles itself as active.
  final String? value;

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;
    final on = active || value != null;
    final text = value ?? label;

    return Semantics(
      button: true,
      label: value == null ? label : '$label: $value',
      child: ExcludeSemantics(
        child: Material(
          color: on ? c.primaryContainer : c.surface,
          shape: StadiumBorder(
            side: BorderSide(color: on ? c.primary : c.border),
          ),
          child: InkWell(
            onTap: onTap,
            customBorder: const StadiumBorder(),
            child: Container(
              constraints: const BoxConstraints(minHeight: SsA11y.minTapTarget - 4),
              padding: const EdgeInsets.symmetric(horizontal: SsSpacing.lg),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    text,
                    style: SsTypeScale.small.copyWith(
                      color: on ? c.onPrimaryContainer : c.onSurface,
                      fontWeight: on ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: SsSpacing.sm),
                  SsIcon(
                    SsIcons.chevronDown,
                    size: SsIconSize.xs,
                    color: on ? c.onPrimaryContainer : c.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// §07.3 The full filter row: an "All" reset chip, a set of dropdown chips,
/// and a "Clear All" action that only appears when something is applied.
class SsFilterBar extends StatelessWidget {
  const SsFilterBar({
    super.key,
    required this.chips,
    this.allSelected = true,
    this.onSelectAll,
    this.onClearAll,
    this.allLabel = 'All',
    this.clearLabel = 'Clear All',
  });

  /// The dropdown chips, in order.
  final List<SsFilterDropdownChip> chips;

  final bool allSelected;
  final VoidCallback? onSelectAll;

  /// Null hides the action — nothing is applied, so there is nothing to clear.
  final VoidCallback? onClearAll;

  final String allLabel;
  final String clearLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;

    return Wrap(
      spacing: SsSpacing.sm,
      runSpacing: SsSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Semantics(
          button: true,
          selected: allSelected,
          label: allLabel,
          child: ExcludeSemantics(
            child: Material(
              color: allSelected ? c.primary : c.surface,
              borderRadius: BorderRadius.circular(SsRadius.md),
              child: InkWell(
                onTap: onSelectAll,
                borderRadius: BorderRadius.circular(SsRadius.md),
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: SsA11y.minTapTarget - 4,
                    minWidth: 56,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: SsSpacing.lg),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(SsRadius.md),
                    border: Border.all(color: allSelected ? c.primary : c.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        allLabel,
                        style: SsTypeScale.small.copyWith(
                          color: allSelected ? c.onPrimary : c.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        ...chips,
        if (onClearAll != null)
          SsButton.tertiary(label: clearLabel, size: SsButtonSize.small, onPressed: onClearAll),
      ],
    );
  }
}
