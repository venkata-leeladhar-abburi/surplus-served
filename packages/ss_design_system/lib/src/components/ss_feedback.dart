import 'package:flutter/material.dart';

import '../artwork/ss_artwork.dart';
import '../icons/ss_icon.dart';
import '../icons/ss_icons.g.dart';
import '../theme/ss_colors.dart';
import '../tokens/tokens.g.dart';
import 'ss_button.dart';

/// §06.6 / §07.13 Alerts and inline feedback.
enum SsAlertTone { success, info, warning, error }

class SsAlert extends StatelessWidget {
  const SsAlert({
    super.key,
    required this.message,
    this.tone = SsAlertTone.info,
    this.onDismiss,
  });

  final String message;
  final SsAlertTone tone;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;
    final (fg, bg, icon) = switch (tone) {
      SsAlertTone.success => (c.onSuccessContainer, c.successContainer, SsIcons.check),
      SsAlertTone.info => (c.onInfoContainer, c.infoContainer, SsIcons.info),
      SsAlertTone.warning => (c.onWarningContainer, c.warningContainer, SsIcons.alert),
      SsAlertTone.error => (c.onErrorContainer, c.errorContainer, SsIcons.alert),
    };

    return Semantics(
      liveRegion: true,
      label: message,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SsSpacing.lg,
          vertical: SsSpacing.md,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(SsRadius.md),
        ),
        child: Row(
          children: [
            SsIcon(icon, size: SsIconSize.md, color: fg),
            const SizedBox(width: SsSpacing.md),
            Expanded(
              child: Text(
                message,
                style: SsTypeScale.small.copyWith(color: c.onSurface),
              ),
            ),
            if (onDismiss != null)
              SsIconButton(
                icon: SsIcons.close,
                tooltip: 'Dismiss',
                onPressed: onDismiss,
              ),
          ],
        ),
      ),
    );
  }
}

/// §07.5 / §06.12 Empty states.
///
/// "Turn empty moments into helpful guidance" — every empty state names what
/// is missing and offers the next best action.
class SsEmptyState extends StatelessWidget {
  const SsEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = SsIcons.receive,
    this.illustration,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.suggestions = const [],
  });

  final String title;
  final String message;
  final SsIconData icon;

  /// The §09 illustration for this state. When set it replaces the icon —
  /// "turn empty moments into helpful guidance" reads far better with the
  /// document's own artwork than with a glyph in a circle.
  final SsArtwork? illustration;

  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  /// Optional "try this next" list — §07.5 shows three by default.
  final List<String> suggestions;

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;

    return Padding(
      padding: const EdgeInsets.all(SsSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (illustration != null)
            SsIllustration(illustration!, width: 168, semanticLabel: '')
          else
            Container(
              height: 96,
              width: 96,
              decoration: BoxDecoration(color: c.primaryContainer, shape: BoxShape.circle),
              child: SsIcon(icon, size: SsIconSize.xl, color: c.primary),
            ),
          const SizedBox(height: SsSpacing.xl),
          Text(
            title,
            textAlign: TextAlign.center,
            style: SsTypeScale.h4.copyWith(color: c.onSurface),
          ),
          const SizedBox(height: SsSpacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: SsTypeScale.body.copyWith(color: c.onSurfaceVariant),
          ),
          if (primaryActionLabel != null) ...[
            const SizedBox(height: SsSpacing.xl),
            SsButton.primary(
              label: primaryActionLabel!,
              onPressed: onPrimaryAction,
              expand: true,
            ),
          ],
          if (secondaryActionLabel != null) ...[
            const SizedBox(height: SsSpacing.md),
            SsButton.secondary(
              label: secondaryActionLabel!,
              onPressed: onSecondaryAction,
              expand: true,
            ),
          ],
          if (suggestions.isNotEmpty) ...[
            const SizedBox(height: SsSpacing.xl),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Suggestions',
                style: SsTypeScale.small.copyWith(
                  color: c.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: SsSpacing.sm),
            for (final s in suggestions)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: SsSpacing.xs),
                child: Row(
                  children: [
                    SsIcon(SsIcons.info, size: SsIconSize.sm, color: c.accent),
                    const SizedBox(width: SsSpacing.sm),
                    Expanded(
                      child: Text(s,
                          style: SsTypeScale.small.copyWith(color: c.onSurfaceVariant)),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// §07.6 Step indicator — Request → Confirm → Pickup → Complete.
class SsStepper extends StatelessWidget {
  const SsStepper({
    super.key,
    required this.steps,
    required this.currentIndex,
  });

  final List<String> steps;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;

    return Semantics(
      label: 'Step ${currentIndex + 1} of ${steps.length}: ${steps[currentIndex]}',
      child: ExcludeSemantics(
        child: Row(
          children: [
            for (var i = 0; i < steps.length; i++) ...[
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 32,
                    width: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i <= currentIndex ? c.primary : c.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: i <= currentIndex ? c.primary : c.border,
                        width: 1.5,
                      ),
                    ),
                    child: i < currentIndex
                        ? SsIcon(SsIcons.check,
                            size: SsIconSize.xs, color: c.onPrimary)
                        : Text(
                            '${i + 1}',
                            style: SsTypeScale.small.copyWith(
                              color: i == currentIndex ? c.onPrimary : c.muted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  const SizedBox(height: SsSpacing.sm),
                  SizedBox(
                    width: 72,
                    child: Text(
                      steps[i],
                      textAlign: TextAlign.center,
                      style: SsTypeScale.caption.copyWith(
                        color: i <= currentIndex ? c.onSurface : c.muted,
                        fontWeight: i == currentIndex ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
              if (i < steps.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: SsSpacing.xxl),
                    color: i < currentIndex ? c.primary : c.border,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
