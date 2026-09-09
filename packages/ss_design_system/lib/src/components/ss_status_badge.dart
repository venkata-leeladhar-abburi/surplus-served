import 'package:flutter/material.dart';

import '../icons/ss_icon.dart';
import '../theme/ss_colors.dart';
import '../tokens/tokens.g.dart';

/// §06.4 Status badges.
///
/// Renders an icon **and** a label alongside the colour, because §03.10 and
/// §10 both forbid conveying meaning by colour alone.
class SsStatusBadge extends StatelessWidget {
  const SsStatusBadge({
    super.key,
    required this.status,
    this.label,
    this.dense = false,
  });

  final SsStatus status;

  /// Localised label. Falls back to the English label baked into the token.
  final String? label;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final pair = context.ssColors.statusColors(status);
    final text = label ?? status.labelEn;

    return Semantics(
      label: 'Status: $text',
      child: ExcludeSemantics(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: dense ? SsSpacing.sm : SsSpacing.md,
            vertical: dense ? 2 : SsSpacing.xs + 2,
          ),
          decoration: BoxDecoration(
            color: pair.bg,
            borderRadius: BorderRadius.circular(SsRadius.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // The icon name travels with the status token, so a new
              // lifecycle state never ships without its glyph.
              SsIcon.named(
                status.iconName,
                size: dense ? SsIconSize.xs : SsIconSize.sm,
                color: pair.fg,
              ),
              SizedBox(width: dense ? SsSpacing.xs : SsSpacing.sm - 2),
              Text(
                text,
                style: (dense ? SsTypeScale.caption : SsTypeScale.small)
                    .copyWith(color: pair.fg, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// §06.4 Content tags — "Vegetarian", "Bulk", "Nearby", "Verified".
class SsTag extends StatelessWidget {
  const SsTag({
    super.key,
    required this.label,
    this.icon,
    this.tone = SsTagTone.neutral,
  });

  final String label;
  final SsIconData? icon;
  final SsTagTone tone;

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;
    final (fg, bg) = switch (tone) {
      SsTagTone.neutral => (c.onSurfaceVariant, c.surfaceAlt),
      SsTagTone.positive => (c.primary, c.primaryContainer),
      SsTagTone.warm => (c.warning, c.warningContainer),
      SsTagTone.info => (c.info, c.infoContainer),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SsSpacing.md,
        vertical: SsSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(SsRadius.pill),
        border: tone == SsTagTone.neutral ? Border.all(color: c.border) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            SsIcon(icon!, size: SsIconSize.xs, color: fg),
            const SizedBox(width: SsSpacing.xs + 2),
          ],
          Text(label, style: SsTypeScale.caption.copyWith(color: fg, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

enum SsTagTone { neutral, positive, warm, info }

/// §02.8 "Time & Freshness" — the ring that reminds people to act soon.
///
/// [remaining] is time left in the pickup window; [total] is the full window.
/// Colour shifts green → orange → red as the window closes, but the minutes
/// are always spelled out so the signal never depends on colour.
class SsFreshnessRing extends StatelessWidget {
  const SsFreshnessRing({
    super.key,
    required this.remaining,
    required this.total,
    this.size = 72,
  });

  final Duration remaining;
  final Duration total;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;
    final fraction = total.inSeconds == 0
        ? 0.0
        : (remaining.inSeconds / total.inSeconds).clamp(0.0, 1.0);

    final color = switch (fraction) {
      >= 0.5 => c.primary,
      >= 0.2 => c.warning,
      _ => c.alert,
    };

    final minutes = remaining.inMinutes;
    final label = minutes >= 60
        ? '${(minutes / 60).floor()} hr left'
        : minutes > 0
            ? '$minutes min left'
            : 'Window closed';

    return Semantics(
      label: 'Pickup window: $label',
      child: ExcludeSemantics(
        child: SizedBox(
          height: size,
          width: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: fraction,
                  strokeWidth: SsIconSize.stroke + 1,
                  strokeCap: StrokeCap.round,
                  color: color,
                  backgroundColor: c.surfaceAlt,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(SsSpacing.sm),
                child: FittedBox(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: SsTypeScale.caption
                        .copyWith(color: color, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// §12 Handover proof — the 4-digit pickup code.
///
/// Shown to the donor once a donation (or split portion) is Allocated; the
/// NGO representative reads or enters it on arrival. This single exchange is
/// the entire proof mechanism for v1.
class SsPickupCode extends StatelessWidget {
  const SsPickupCode({super.key, required this.code, this.caption});

  final String code;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;
    final digits = code.split('');

    return Semantics(
      label: 'Pickup code ${digits.join(' ')}',
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final d in digits)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: SsSpacing.xs),
                    height: 64,
                    width: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: c.primaryContainer,
                      borderRadius: BorderRadius.circular(SsRadius.md),
                      border: Border.all(color: c.primary.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      d,
                      style: SsTypeScale.h3.copyWith(color: c.onPrimaryContainer),
                    ),
                  ),
              ],
            ),
            if (caption != null) ...[
              const SizedBox(height: SsSpacing.md),
              Text(
                caption!,
                textAlign: TextAlign.center,
                style: SsTypeScale.small.copyWith(color: c.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
