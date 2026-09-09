import 'package:flutter/material.dart';

import '../icons/ss_icon.dart';
import '../icons/ss_icons.g.dart';
import '../theme/ss_colors.dart';
import '../tokens/tokens.g.dart';

/// §06.8 Dropdown / select.
///
/// Matches the input field's shape and height exactly, so a form that mixes
/// typed and chosen values reads as one row of controls rather than two.
class SsDropdown<T> extends StatelessWidget {
  const SsDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.label,
    this.hint = 'Select',
    this.prefixIcon,
    this.labelBuilder,
    this.enabled = true,
    this.errorText,
    this.helper,
  });

  final List<T> items;
  final ValueChanged<T?>? onChanged;
  final T? value;
  final String? label;
  final String hint;
  final SsIconData? prefixIcon;
  final String Function(T)? labelBuilder;
  final bool enabled;
  final String? errorText;
  final String? helper;

  String _label(T v) => labelBuilder?.call(v) ?? v.toString();

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
        DropdownButtonFormField<T>(
          initialValue: value,
          onChanged: enabled ? onChanged : null,
          isExpanded: true,
          icon: SsIcon(
            SsIcons.chevronDown,
            size: SsIconSize.sm,
            color: enabled ? c.onSurfaceVariant : c.muted,
          ),
          hint: Text(hint, style: SsTypeScale.body.copyWith(color: c.muted)),
          style: SsTypeScale.body.copyWith(color: enabled ? c.onSurface : c.muted),
          dropdownColor: c.surface,
          borderRadius: BorderRadius.circular(SsRadius.md),
          decoration: InputDecoration(
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
          ),
          items: [
            for (final item in items)
              DropdownMenuItem<T>(value: item, child: Text(_label(item))),
          ],
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
                  child: Text(errorText!,
                      style: SsTypeScale.caption.copyWith(color: c.error)),
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

/// §06.8 / §07.15 Checkbox with a label.
///
/// The whole row is the tap target, and [linkText] renders the underlined
/// portion — "I agree to the terms and conditions" — as its own control so it
/// is reachable without toggling the box.
class SsCheckbox extends StatelessWidget {
  const SsCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.linkText,
    this.onLinkTap,
    this.enabled = true,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String label;

  /// Rendered underlined after [label] and tappable on its own.
  final String? linkText;
  final VoidCallback? onLinkTap;

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;
    final active = enabled && onChanged != null;

    return Semantics(
      checked: value,
      enabled: active,
      label: [label, if (linkText != null) linkText].whereType<String>().join(' '),
      child: ExcludeSemantics(
        child: InkWell(
          onTap: active ? () => onChanged!(!value) : null,
          borderRadius: BorderRadius.circular(SsRadius.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: SsSpacing.sm),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Box(value: value, enabled: active, colors: c),
                const SizedBox(width: SsSpacing.md),
                Flexible(
                  child: Text.rich(
                    TextSpan(
                      style: SsTypeScale.body.copyWith(
                        color: active ? c.onSurface : c.muted,
                      ),
                      children: [
                        TextSpan(text: label),
                        if (linkText != null) ...[
                          const TextSpan(text: ' '),
                          TextSpan(
                            text: linkText,
                            style: TextStyle(
                              color: active ? c.primary : c.muted,
                              decoration: TextDecoration.underline,
                              decorationColor: active ? c.primary : c.muted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.value, required this.enabled, required this.colors});

  final bool value;
  final bool enabled;
  final SsColors colors;

  @override
  Widget build(BuildContext context) {
    final fill = !enabled
        ? colors.surfaceAlt
        : value
            ? colors.primary
            : Colors.transparent;

    return AnimatedContainer(
      duration: SsDuration.fast,
      height: 22,
      width: 22,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(SsRadius.xs + 2),
        border: Border.all(
          color: !enabled
              ? colors.border
              : value
                  ? colors.primary
                  : colors.border,
          width: 1.5,
        ),
      ),
      child: value
          ? SsIcon(
              SsIcons.check,
              size: 16,
              color: enabled ? colors.onPrimary : colors.muted,
              strokeWidth: 3,
            )
          : null,
    );
  }
}

/// §06.8 / §07.15 Radio group — "Individual / Organization".
class SsRadioGroup<T> extends StatelessWidget {
  const SsRadioGroup({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.labelBuilder,
    this.axis = Axis.horizontal,
    this.disabledOptions = const {},
  });

  final List<T> options;
  final T? value;
  final ValueChanged<T>? onChanged;
  final String Function(T)? labelBuilder;
  final Axis axis;
  final Set<T> disabledOptions;

  String _label(T v) => labelBuilder?.call(v) ?? v.toString();

  @override
  Widget build(BuildContext context) {
    final children = [
      for (final option in options)
        _Radio<T>(
          label: _label(option),
          selected: option == value,
          enabled: onChanged != null && !disabledOptions.contains(option),
          onTap: () => onChanged?.call(option),
        ),
    ];

    return axis == Axis.horizontal
        ? Wrap(spacing: SsSpacing.xxl, runSpacing: SsSpacing.sm, children: children)
        : Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }
}

class _Radio<T> extends StatelessWidget {
  const _Radio({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;
    final ring = !enabled
        ? c.border
        : selected
            ? c.primary
            : c.border;

    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      enabled: enabled,
      label: label,
      child: ExcludeSemantics(
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(SsRadius.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: SsSpacing.sm),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 22,
                  width: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: !enabled ? c.surfaceAlt : Colors.transparent,
                    border: Border.all(color: ring, width: 2),
                  ),
                  child: selected
                      ? Center(
                          child: Container(
                            height: 10,
                            width: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: enabled ? c.primary : c.muted,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: SsSpacing.md),
                Text(
                  label,
                  style: SsTypeScale.body.copyWith(
                    color: enabled ? c.onSurface : c.muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// §06.8 / §07.15 Toggle switch, with an optional caption beneath the label.
class SsSwitch extends StatelessWidget {
  const SsSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.caption,
    this.enabled = true,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;

  /// Secondary line under the label — "Receive notifications".
  final String? caption;

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;
    final active = enabled && onChanged != null;

    final control = Switch(
      value: value,
      onChanged: active ? onChanged : null,
    );

    if (label == null && caption == null) {
      return Semantics(toggled: value, enabled: active, child: control);
    }

    return Semantics(
      toggled: value,
      enabled: active,
      label: [label, caption].whereType<String>().join(', '),
      child: ExcludeSemantics(
        child: InkWell(
          onTap: active ? () => onChanged!(!value) : null,
          borderRadius: BorderRadius.circular(SsRadius.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: SsSpacing.xs),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                control,
                const SizedBox(width: SsSpacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (label != null)
                      Text(
                        label!,
                        style: SsTypeScale.body.copyWith(
                          color: active ? c.onSurface : c.muted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    if (caption != null)
                      Text(
                        caption!,
                        style: SsTypeScale.small.copyWith(color: c.onSurfaceVariant),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// §07.7 Slider — "Distance … 25 km", with the range spelled out beneath.
///
/// The current value is always rendered as text, not just as a thumb position:
/// an NGO setting a service radius needs the number, not an impression.
class SsSlider extends StatelessWidget {
  const SsSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.label,
    this.divisions,
    this.formatValue,
    this.enabled = true,
  });

  final double value;
  final double min;
  final double max;
  final ValueChanged<double>? onChanged;
  final String? label;
  final int? divisions;

  /// Turns a value into its display string — defaults to a plain integer.
  final String Function(double)? formatValue;

  final bool enabled;

  String _fmt(double v) => formatValue?.call(v) ?? v.round().toString();

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;
    final active = enabled && onChanged != null;

    return Semantics(
      slider: true,
      enabled: active,
      label: label,
      value: _fmt(value),
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label!,
                    style: SsTypeScale.small.copyWith(color: c.onSurfaceVariant),
                  ),
                  Text(
                    _fmt(value),
                    style: SsTypeScale.small.copyWith(
                      color: active ? c.primary : c.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 6,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 11,
                  elevation: 1,
                ),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                activeTrackColor: active ? c.primary : c.muted,
                inactiveTrackColor: c.surfaceAlt,
                thumbColor: c.surface,
                // A white thumb ringed in the brand green, as drawn in §07.7.
                overlayColor: c.primary.withValues(alpha: 0.12),
              ),
              child: Slider(
                value: value.clamp(min, max),
                min: min,
                max: max,
                divisions: divisions,
                onChanged: active ? onChanged : null,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_fmt(min), style: SsTypeScale.caption.copyWith(color: c.muted)),
                Text(_fmt(max), style: SsTypeScale.caption.copyWith(color: c.muted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
