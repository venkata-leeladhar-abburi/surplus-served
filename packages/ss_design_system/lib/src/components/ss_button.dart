import 'package:flutter/material.dart';

import '../icons/ss_icon.dart';
import '../theme/ss_colors.dart';
import '../tokens/tokens.g.dart';

/// §06.1 Button hierarchy.
///
/// * [primary]   — the one action that moves food forward ("Donate Food").
/// * [secondary] — an equal-weight alternative ("Find Nearby").
/// * [tertiary]  — low-emphasis navigation ("Learn More →").
/// * [danger]    — destructive and irreversible ("Cancel Listing").
enum SsButtonVariant { primary, secondary, tertiary, danger }

enum SsButtonSize { small, medium, large }

/// A button that always meets the 44×44 tap-target floor (§10.7) and always
/// exposes a semantic label to screen readers.
class SsButton extends StatelessWidget {
  const SsButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = SsButtonVariant.primary,
    this.size = SsButtonSize.medium,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.expand = false,
    this.semanticLabel,
  });

  const SsButton.primary({
    super.key,
    required this.label,
    this.onPressed,
    this.size = SsButtonSize.medium,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.expand = false,
    this.semanticLabel,
  }) : variant = SsButtonVariant.primary;

  const SsButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.size = SsButtonSize.medium,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.expand = false,
    this.semanticLabel,
  }) : variant = SsButtonVariant.secondary;

  const SsButton.tertiary({
    super.key,
    required this.label,
    this.onPressed,
    this.size = SsButtonSize.medium,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.expand = false,
    this.semanticLabel,
  }) : variant = SsButtonVariant.tertiary;

  const SsButton.danger({
    super.key,
    required this.label,
    this.onPressed,
    this.size = SsButtonSize.medium,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.expand = false,
    this.semanticLabel,
  }) : variant = SsButtonVariant.danger;

  final String label;
  final VoidCallback? onPressed;
  final SsButtonVariant variant;
  final SsButtonSize size;
  final SsIconData? icon;
  final SsIconData? trailingIcon;
  final bool isLoading;
  final bool expand;
  final String? semanticLabel;

  double get _minHeight => switch (size) {
        SsButtonSize.small => SsA11y.minTapTarget,
        SsButtonSize.medium => SsA11y.minTapTarget + 4,
        SsButtonSize.large => 56,
      };

  EdgeInsets get _padding => switch (size) {
        SsButtonSize.small =>
          const EdgeInsets.symmetric(horizontal: SsSpacing.lg, vertical: SsSpacing.sm),
        SsButtonSize.medium =>
          const EdgeInsets.symmetric(horizontal: SsSpacing.xl, vertical: SsSpacing.md),
        SsButtonSize.large =>
          const EdgeInsets.symmetric(horizontal: SsSpacing.xxl, vertical: SsSpacing.lg),
      };

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;
    final enabled = onPressed != null && !isLoading;

    final child = _Content(
      label: label,
      icon: icon,
      trailingIcon: trailingIcon,
      isLoading: isLoading,
      size: size,
    );

    final button = switch (variant) {
      SsButtonVariant.primary => ElevatedButton(
          onPressed: enabled ? onPressed : null,
          style: _sizeOverride(),
          child: child,
        ),
      SsButtonVariant.secondary => OutlinedButton(
          onPressed: enabled ? onPressed : null,
          style: _sizeOverride(),
          child: child,
        ),
      SsButtonVariant.tertiary => TextButton(
          onPressed: enabled ? onPressed : null,
          style: _sizeOverride(),
          child: child,
        ),
      SsButtonVariant.danger => ElevatedButton(
          onPressed: enabled ? onPressed : null,
          style: _sizeOverride().copyWith(
            backgroundColor: WidgetStateProperty.resolveWith(
              (s) => s.contains(WidgetState.disabled) ? c.surfaceAlt : c.alert,
            ),
            foregroundColor: WidgetStateProperty.resolveWith(
              (s) => s.contains(WidgetState.disabled) ? c.muted : c.onAlert,
            ),
          ),
          child: child,
        ),
    };

    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel ?? label,
      child: ExcludeSemantics(
        child: expand ? SizedBox(width: double.infinity, child: button) : button,
      ),
    );
  }

  ButtonStyle _sizeOverride() => ButtonStyle(
        minimumSize: WidgetStateProperty.all(Size(expand ? double.infinity : 0, _minHeight)),
        padding: WidgetStateProperty.all(_padding),
      );
}

class _Content extends StatelessWidget {
  const _Content({
    required this.label,
    required this.icon,
    required this.trailingIcon,
    required this.isLoading,
    required this.size,
  });

  final String label;
  final SsIconData? icon;
  final SsIconData? trailingIcon;
  final bool isLoading;
  final SsButtonSize size;

  @override
  Widget build(BuildContext context) {
    final iconSize = size == SsButtonSize.small ? SsIconSize.sm : SsIconSize.md;

    if (isLoading) {
      return SizedBox(
        height: iconSize,
        width: iconSize,
        child: CircularProgressIndicator(
          strokeWidth: SsIconSize.stroke,
          strokeCap: StrokeCap.round,
          color: DefaultTextStyle.of(context).style.color,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          SsIcon(icon!, size: iconSize),
          const SizedBox(width: SsSpacing.sm),
        ],
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        if (trailingIcon != null) ...[
          const SizedBox(width: SsSpacing.sm),
          SsIcon(trailingIcon!, size: iconSize),
        ],
      ],
    );
  }
}

/// §06.1 Icon button — circular, always 44×44 minimum.
class SsIconButton extends StatelessWidget {
  const SsIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.filled = false,
    this.plain = false,
  });

  final SsIconData icon;

  /// Doubles as the screen-reader label — an icon button is never unlabelled.
  final String tooltip;
  final VoidCallback? onPressed;
  final bool filled;

  /// No background — for quiet placements like a modal's close control.
  final bool plain;

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: SizedBox(
          height: SsA11y.minTapTarget,
          width: SsA11y.minTapTarget,
          child: Material(
            color: plain
                ? Colors.transparent
                : filled
                    ? c.primary
                    : c.primaryContainer,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              child: SsIcon(
                icon,
                size: SsIconSize.md,
                color: plain
                    ? c.onSurfaceVariant
                    : filled
                        ? c.onPrimary
                        : c.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
