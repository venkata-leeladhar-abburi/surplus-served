import 'package:flutter/material.dart';

import '../icons/ss_icon.dart';
import '../icons/ss_icons.g.dart';
import '../theme/ss_colors.dart';
import '../tokens/tokens.g.dart';
import 'ss_button.dart';

/// §07.11 Avatar — a person or an organisation.
///
/// Falls back to initials on the brand tint rather than a grey silhouette, so
/// an NGO without a logo still reads as a real, identified organisation.
class SsAvatar extends StatelessWidget {
  const SsAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 44,
    this.verified = false,
    this.online = false,
  });

  final String name;
  final String? imageUrl;
  final double size;

  /// Admin-approved NGO (scope §5.1). Shown as a badge, never as colour alone.
  final bool verified;
  final bool online;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;
    final badge = size >= 36;

    return Semantics(
      label: [name, if (verified) 'verified', if (online) 'online'].join(', '),
      image: true,
      child: ExcludeSemantics(
        child: SizedBox(
          height: size,
          width: size,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: ClipOval(
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _initialsBox(c),
                        )
                      : _initialsBox(c),
                ),
              ),
              if (verified && badge)
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: c.surface,
                      shape: BoxShape.circle,
                    ),
                    child: SsIcon(
                      SsIcons.verified,
                      size: size * 0.34,
                      color: c.info,
                    ),
                  ),
                ),
              if (online && badge)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    height: size * 0.22,
                    width: size * 0.22,
                    decoration: BoxDecoration(
                      color: c.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: c.surface, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _initialsBox(SsColors c) => ColoredBox(
        color: c.primaryContainer,
        child: Center(
          child: Text(
            _initials,
            style: SsTypeScale.body.copyWith(
              color: c.onPrimaryContainer,
              fontWeight: FontWeight.w600,
              fontSize: size * 0.36,
            ),
          ),
        ),
      );
}

/// §07.2 List item — "Green Bites Café · Donor · 2 km away".
class SsListTile extends StatelessWidget {
  const SsListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.showChevron = true,
    this.dense = false,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;

    return Semantics(
      button: onTap != null,
      label: [title, if (subtitle != null) subtitle].whereType<String>().join(', '),
      child: ExcludeSemantics(
        child: Material(
          color: c.surface,
          borderRadius: BorderRadius.circular(SsRadius.md),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(SsRadius.md),
            child: Container(
              constraints: const BoxConstraints(minHeight: SsA11y.minTapTarget + 12),
              padding: EdgeInsets.symmetric(
                horizontal: SsSpacing.lg,
                vertical: dense ? SsSpacing.sm : SsSpacing.md,
              ),
              child: Row(
                children: [
                  if (leading != null) ...[
                    leading!,
                    const SizedBox(width: SsSpacing.md),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: SsTypeScale.body.copyWith(
                            color: c.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: SsTypeScale.small.copyWith(color: c.onSurfaceVariant),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: SsSpacing.md),
                    trailing!,
                  ] else if (showChevron && onTap != null) ...[
                    const SizedBox(width: SsSpacing.sm),
                    SsIcon(SsIcons.chevronRight, size: SsIconSize.sm, color: c.muted),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// §07.5 Accordion — the FAQ pattern from "How does food rescue work?".
class SsAccordion extends StatefulWidget {
  const SsAccordion({super.key, required this.items, this.initiallyExpanded});

  final List<SsAccordionItem> items;

  /// Index of the panel open on first build; null means all closed.
  final int? initiallyExpanded;

  @override
  State<SsAccordion> createState() => _SsAccordionState();
}

class SsAccordionItem {
  const SsAccordionItem({required this.title, required this.body});
  final String title;
  final String body;
}

class _SsAccordionState extends State<SsAccordion> {
  late int? _open = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;

    return Column(
      children: [
        for (var i = 0; i < widget.items.length; i++)
          Padding(
            padding: EdgeInsets.only(
              bottom: i == widget.items.length - 1 ? 0 : SsSpacing.sm,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: c.surface,
                border: Border.all(color: c.border),
                borderRadius: BorderRadius.circular(SsRadius.md),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Semantics(
                    button: true,
                    expanded: _open == i,
                    label: widget.items[i].title,
                    child: ExcludeSemantics(
                      child: InkWell(
                        onTap: () => setState(() => _open = _open == i ? null : i),
                        child: Container(
                          constraints:
                              const BoxConstraints(minHeight: SsA11y.minTapTarget),
                          padding: const EdgeInsets.all(SsSpacing.lg),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.items[i].title,
                                  style: SsTypeScale.body.copyWith(
                                    color: c.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              AnimatedRotation(
                                turns: _open == i ? 0.5 : 0,
                                duration: SsDuration.fast,
                                child: SsIcon(
                                  SsIcons.chevronDown,
                                  size: SsIconSize.sm,
                                  color: c.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  AnimatedCrossFade(
                    duration: SsDuration.fast,
                    crossFadeState: _open == i
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: const SizedBox(width: double.infinity),
                    secondChild: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(
                        SsSpacing.lg, 0, SsSpacing.lg, SsSpacing.lg,
                      ),
                      child: Text(
                        widget.items[i].body,
                        style: SsTypeScale.small.copyWith(color: c.onSurfaceVariant),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// §07.14 Notification row — "New food available near you · 2 min ago".
class SsNotificationTile extends StatelessWidget {
  const SsNotificationTile({
    super.key,
    required this.title,
    required this.body,
    required this.timeAgo,
    this.icon = SsIcons.bell,
    this.tone = SsNotificationTone.neutral,
    this.unread = false,
    this.onTap,
  });

  final String title;
  final String body;
  final String timeAgo;
  final SsIconData icon;
  final SsNotificationTone tone;
  final bool unread;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;
    final (fg, bg) = switch (tone) {
      SsNotificationTone.neutral => (c.primary, c.primaryContainer),
      SsNotificationTone.success => (c.onSuccessContainer, c.successContainer),
      SsNotificationTone.warning => (c.onWarningContainer, c.warningContainer),
      SsNotificationTone.error => (c.onErrorContainer, c.errorContainer),
    };

    return Semantics(
      button: onTap != null,
      label: '${unread ? 'Unread. ' : ''}$title. $body. $timeAgo',
      child: ExcludeSemantics(
        child: Material(
          color: unread ? c.primaryContainer.withValues(alpha: 0.35) : c.surface,
          borderRadius: BorderRadius.circular(SsRadius.md),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(SsRadius.md),
            child: Padding(
              padding: const EdgeInsets.all(SsSpacing.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                    child: SsIcon(icon, size: SsIconSize.sm, color: fg),
                  ),
                  const SizedBox(width: SsSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: SsTypeScale.body.copyWith(
                                  color: c.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: SsSpacing.sm),
                            Text(
                              timeAgo,
                              style: SsTypeScale.caption.copyWith(color: c.muted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          body,
                          style: SsTypeScale.small.copyWith(color: c.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  if (unread) ...[
                    const SizedBox(width: SsSpacing.sm),
                    Container(
                      height: 8,
                      width: 8,
                      margin: const EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(color: c.accent, shape: BoxShape.circle),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum SsNotificationTone { neutral, success, warning, error }

/// §06.9 Progress bar with an optional "3 of 5 steps" caption.
class SsProgressBar extends StatelessWidget {
  const SsProgressBar({
    super.key,
    required this.value,
    this.label,
    this.tone,
  });

  /// 0.0 – 1.0. Pass null for an indeterminate bar.
  final double? value;
  final String? label;
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;

    return Semantics(
      label: label,
      value: value == null ? null : '${(value! * 100).round()} percent',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(SsRadius.pill),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 8,
                color: tone ?? c.primary,
                backgroundColor: c.surfaceAlt,
              ),
            ),
            if (label != null) ...[
              const SizedBox(height: SsSpacing.sm),
              Text(label!, style: SsTypeScale.caption.copyWith(color: c.onSurfaceVariant)),
            ],
          ],
        ),
      ),
    );
  }
}

/// §07.10 Location row — the address block that unlocks on allocation.
///
/// Scope §11: while a donation is Live only an approximate locality is shown;
/// the exact address and phone appear once an NGO holds the allocation. The
/// [locked] flag makes that state visible instead of showing a blank.
class SsLocationRow extends StatelessWidget {
  const SsLocationRow({
    super.key,
    required this.address,
    this.contactName,
    this.phone,
    this.locked = false,
    this.onDirections,
    this.onCall,
  });

  final String address;
  final String? contactName;
  final String? phone;
  final bool locked;
  final VoidCallback? onDirections;
  final VoidCallback? onCall;

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;

    return Container(
      padding: const EdgeInsets.all(SsSpacing.lg),
      decoration: BoxDecoration(
        color: c.surfaceAlt,
        borderRadius: BorderRadius.circular(SsRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SsIcon(
                locked ? SsIcons.eyeOff : SsIcons.location,
                size: SsIconSize.sm,
                color: locked ? c.muted : c.primary,
              ),
              const SizedBox(width: SsSpacing.md),
              Expanded(
                child: Text(
                  address,
                  style: SsTypeScale.body.copyWith(
                    color: locked ? c.onSurfaceVariant : c.onSurface,
                  ),
                ),
              ),
            ],
          ),
          if (locked) ...[
            const SizedBox(height: SsSpacing.sm),
            Text(
              'The exact address and contact unlock once you are allocated this donation.',
              style: SsTypeScale.caption.copyWith(color: c.muted),
            ),
          ],
          if (!locked && contactName != null) ...[
            const SizedBox(height: SsSpacing.md),
            Row(
              children: [
                SsIcon(SsIcons.user, size: SsIconSize.sm, color: c.onSurfaceVariant),
                const SizedBox(width: SsSpacing.md),
                Expanded(
                  child: Text(
                    [contactName, phone].whereType<String>().join(' · '),
                    style: SsTypeScale.body.copyWith(color: c.onSurface),
                  ),
                ),
              ],
            ),
          ],
          if (!locked && (onDirections != null || onCall != null)) ...[
            const SizedBox(height: SsSpacing.lg),
            Row(
              children: [
                if (onDirections != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onDirections,
                      icon: const SsIcon(SsIcons.map, size: SsIconSize.sm),
                      label: const Text('Directions'),
                    ),
                  ),
                if (onDirections != null && onCall != null)
                  const SizedBox(width: SsSpacing.md),
                if (onCall != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onCall,
                      icon: const SsIcon(SsIcons.phone, size: SsIconSize.sm),
                      label: const Text('Call'),
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

/// §06.3 Stat card — "1,240 kg / Food Saved This Month", with a sparkline and
/// a delta.
///
/// The delta carries an arrow as well as a colour, so the direction survives
/// greyscale and colour-blind readers (§03).
class SsStatCard extends StatelessWidget {
  const SsStatCard({
    super.key,
    required this.value,
    required this.label,
    this.icon = SsIcons.leaf,
    this.sparkline = const [],
    this.delta,
    this.deltaDirection = SsDelta.flat,
  });

  final String value;
  final String label;
  final SsIconData icon;

  /// Relative values; only their proportions matter.
  final List<double> sparkline;

  final String? delta;
  final SsDelta deltaDirection;

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;
    final max = sparkline.isEmpty ? 0.0 : sparkline.reduce((a, b) => a > b ? a : b);
    final deltaColor = switch (deltaDirection) {
      SsDelta.up => c.success,
      SsDelta.down => c.error,
      SsDelta.flat => c.onSurfaceVariant,
    };

    return Semantics(
      label: [value, label, if (delta != null) delta].whereType<String>().join(', '),
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.all(SsSpacing.lg),
          decoration: BoxDecoration(
            color: c.surface,
            border: Border.all(color: c.border),
            borderRadius: BorderRadius.circular(SsRadius.lg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: c.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: SsIcon(icon, size: SsIconSize.md, color: c.primary),
              ),
              const SizedBox(height: SsSpacing.lg),
              Text(value, style: SsTypeScale.h3.copyWith(color: c.onSurface)),
              Text(label, style: SsTypeScale.small.copyWith(color: c.onSurfaceVariant)),
              if (sparkline.isNotEmpty) ...[
                const SizedBox(height: SsSpacing.lg),
                SizedBox(
                  height: 44,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (var i = 0; i < sparkline.length; i++) ...[
                        Expanded(
                          child: Container(
                            height: max == 0
                                ? 3
                                : (sparkline[i] / max * 44).clamp(3.0, 44.0),
                            decoration: BoxDecoration(
                              color: c.primary.withValues(
                                alpha: 0.3 + 0.7 * ((i + 1) / sparkline.length),
                              ),
                              borderRadius: BorderRadius.circular(SsRadius.xs),
                            ),
                          ),
                        ),
                        if (i < sparkline.length - 1) const SizedBox(width: 3),
                      ],
                    ],
                  ),
                ),
              ],
              if (delta != null) ...[
                const SizedBox(height: SsSpacing.md),
                Row(
                  children: [
                    SsIcon(
                      deltaDirection == SsDelta.down
                          ? SsIcons.chevronDown
                          : SsIcons.chevronUp,
                      size: SsIconSize.xs,
                      color: deltaColor,
                    ),
                    const SizedBox(width: SsSpacing.xs),
                    Text(
                      delta!,
                      style: SsTypeScale.small.copyWith(
                        color: deltaColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

enum SsDelta { up, down, flat }

/// §07.10 Map and location.
///
/// The design system owns the map's *chrome* — the callout, the zoom controls
/// and the confirm button — while the tiles themselves come from Google Maps
/// in the app layer. Pass the live map as [mapLayer]; the placeholder grid
/// renders when it is null so this composes in previews and tests.
class SsMapCard extends StatelessWidget {
  const SsMapCard({
    super.key,
    this.mapLayer,
    this.calloutTitle,
    this.calloutSubtitle,
    this.actionLabel = 'Set Location',
    this.onAction,
    this.onZoomIn,
    this.onZoomOut,
    this.height = 220,
    this.showPin = true,
  });

  /// The real map widget. Null renders the placeholder grid.
  final Widget? mapLayer;

  final String? calloutTitle;
  final String? calloutSubtitle;
  final String actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;
  final double height;
  final bool showPin;

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;

    return ClipRRect(
      borderRadius: BorderRadius.circular(SsRadius.lg),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: mapLayer ??
                  CustomPaint(
                    painter: _MapPlaceholderPainter(
                      ground: c.surfaceAlt,
                      road: c.surface,
                      park: c.primaryContainer,
                    ),
                  ),
            ),
            if (showPin)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SsIcon(
                    SsIcons.map,
                    size: SsIconSize.lg,
                    color: c.primary,
                    filled: true,
                  ),
                ),
              ),
            if (calloutTitle != null)
              Positioned(
                top: SsSpacing.lg,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SsSpacing.lg,
                      vertical: SsSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(SsRadius.md),
                      boxShadow: SsShadows.md,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          calloutTitle!,
                          style: SsTypeScale.body.copyWith(
                            color: c.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (calloutSubtitle != null)
                          Text(
                            calloutSubtitle!,
                            style: SsTypeScale.small
                                .copyWith(color: c.onSurfaceVariant),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            if (onZoomIn != null || onZoomOut != null)
              Positioned(
                top: SsSpacing.lg,
                right: SsSpacing.lg,
                child: Container(
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(SsRadius.sm),
                    boxShadow: SsShadows.sm,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ZoomButton(
                        icon: SsIcons.plus,
                        tooltip: 'Zoom in',
                        onPressed: onZoomIn,
                      ),
                      Container(height: 1, width: 28, color: c.border),
                      _ZoomButton(
                        icon: SsIcons.minus,
                        tooltip: 'Zoom out',
                        onPressed: onZoomOut,
                      ),
                    ],
                  ),
                ),
              ),
            if (onAction != null)
              Positioned(
                right: SsSpacing.lg,
                bottom: SsSpacing.lg,
                child: SsButton.secondary(label: actionLabel, onPressed: onAction),
              ),
          ],
        ),
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  const _ZoomButton({required this.icon, required this.tooltip, this.onPressed});

  final SsIconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          height: SsA11y.minTapTarget,
          width: SsA11y.minTapTarget,
          child: SsIcon(icon, size: SsIconSize.sm, color: c.onSurface),
        ),
      ),
    );
  }
}

/// A stylised street grid, so the map chrome can be laid out and reviewed
/// without a network round-trip or an API key.
class _MapPlaceholderPainter extends CustomPainter {
  const _MapPlaceholderPainter({
    required this.ground,
    required this.road,
    required this.park,
  });

  final Color ground;
  final Color road;
  final Color park;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = ground);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-size.width * 0.1, size.height * 0.62, size.width * 0.45,
            size.height * 0.5),
        const Radius.circular(24),
      ),
      Paint()..color = park,
    );

    final roads = Paint()
      ..color = road
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7;

    for (var i = -2; i < 6; i++) {
      final x = size.width * (i / 4);
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), roads);
      canvas.drawLine(
        Offset(x + size.height, 0),
        Offset(x, size.height),
        roads..strokeWidth = 4,
      );
    }
  }

  @override
  bool shouldRepaint(_MapPlaceholderPainter old) =>
      old.ground != ground || old.road != road || old.park != park;
}
