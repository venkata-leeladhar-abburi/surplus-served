import 'package:flutter/material.dart';

import '../icons/ss_icon.dart';
import '../icons/ss_icons.g.dart';
import '../theme/ss_colors.dart';
import '../tokens/tokens.g.dart';
import 'ss_button.dart';
import 'ss_status_badge.dart';

/// §06.3 / §08 Food card — the single most-repeated surface in the product.
///
/// Every field on it answers a question an NGO asks before deciding to
/// request: what, from whom, how far, how long, how much, veg or not.
class SsDonationCard extends StatelessWidget {
  const SsDonationCard({
    super.key,
    required this.title,
    required this.donorName,
    required this.imageUrl,
    required this.status,
    this.distanceLabel,
    this.timeLeftLabel,
    this.servingsLabel,
    this.isVegetarian,
    this.tags = const [],
    this.actionLabel,
    this.onAction,
    this.onTap,
    this.isSaved = false,
    this.onToggleSave,
  });

  final String title;
  final String donorName;

  /// Null renders the illustrated placeholder rather than a broken frame.
  final String? imageUrl;
  final SsStatus status;

  final String? distanceLabel;
  final String? timeLeftLabel;
  final String? servingsLabel;
  final bool? isVegetarian;
  final List<SsTag> tags;

  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onTap;

  final bool isSaved;
  final VoidCallback? onToggleSave;

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;

    return Semantics(
      button: onTap != null,
      label: [
        title,
        'from $donorName',
        if (distanceLabel != null) distanceLabel,
        if (timeLeftLabel != null) timeLeftLabel,
        if (servingsLabel != null) servingsLabel,
        'Status: ${status.labelEn}',
      ].whereType<String>().join(', '),
      child: ExcludeSemantics(
        child: Material(
          color: c.surface,
          borderRadius: BorderRadius.circular(SsRadius.lg),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: c.border),
                borderRadius: BorderRadius.circular(SsRadius.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Media(
                    imageUrl: imageUrl,
                    status: status,
                    isSaved: isSaved,
                    onToggleSave: onToggleSave,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(SsSpacing.cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: SsTypeScale.h5.copyWith(
                            color: c.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: SsSpacing.xs),
                        Text(
                          donorName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: SsTypeScale.small.copyWith(color: c.onSurfaceVariant),
                        ),
                        const SizedBox(height: SsSpacing.md),
                        Wrap(
                          spacing: SsSpacing.lg,
                          runSpacing: SsSpacing.sm,
                          children: [
                            if (distanceLabel != null)
                              _Meta(icon: SsIcons.location, label: distanceLabel!),
                            if (timeLeftLabel != null)
                              _Meta(icon: SsIcons.time, label: timeLeftLabel!),
                            if (servingsLabel != null)
                              _Meta(icon: SsIcons.meals, label: servingsLabel!),
                          ],
                        ),
                        if (isVegetarian != null || tags.isNotEmpty) ...[
                          const SizedBox(height: SsSpacing.md),
                          Wrap(
                            spacing: SsSpacing.sm,
                            runSpacing: SsSpacing.sm,
                            children: [
                              if (isVegetarian != null)
                                SsTag(
                                  label: isVegetarian! ? 'Vegetarian' : 'Non-vegetarian',
                                  icon: SsIcons.leaf,
                                  tone: isVegetarian! ? SsTagTone.positive : SsTagTone.warm,
                                ),
                              ...tags,
                            ],
                          ),
                        ],
                        // §13 Containers — a persistent reminder on every
                        // donation surface. No container logistics is built.
                        const SizedBox(height: SsSpacing.md),
                        Row(
                          children: [
                            SsIcon(SsIcons.info, size: SsIconSize.xs, color: c.muted),
                            const SizedBox(width: SsSpacing.xs + 2),
                            Expanded(
                              child: Text(
                                'Please bring your own containers.',
                                style: SsTypeScale.caption.copyWith(color: c.muted),
                              ),
                            ),
                          ],
                        ),
                        if (actionLabel != null) ...[
                          const SizedBox(height: SsSpacing.lg),
                          SsButton.primary(
                            label: actionLabel!,
                            onPressed: onAction,
                            expand: true,
                          ),
                        ],
                      ],
                    ),
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

class _Media extends StatelessWidget {
  const _Media({
    required this.imageUrl,
    required this.status,
    required this.isSaved,
    required this.onToggleSave,
  });

  final String? imageUrl;
  final SsStatus status;
  final bool isSaved;
  final VoidCallback? onToggleSave;

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;

    return SizedBox(
      height: 160,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl != null)
            Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(c),
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : _placeholder(c),
            )
          else
            _placeholder(c),
          Positioned(
            top: SsSpacing.md,
            left: SsSpacing.md,
            child: SsStatusBadge(status: status, dense: true),
          ),
          if (onToggleSave != null)
            Positioned(
              top: SsSpacing.sm,
              right: SsSpacing.sm,
              child: SsIconButton(
                icon: SsIcons.donate,
                filled: isSaved,
                tooltip: isSaved ? 'Remove from saved' : 'Save for later',
                onPressed: onToggleSave,
              ),
            ),
        ],
      ),
    );
  }

  Widget _placeholder(SsColors c) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: c.natureGradient.map((x) => x.withValues(alpha: 0.15)).toList(),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SsIcon(SsIcons.leaf, size: SsIconSize.xl, color: c.primary),
        ),
      );
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label});

  final SsIconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SsIcon(icon, size: SsIconSize.xs + 2, color: c.onSurfaceVariant),
        const SizedBox(width: SsSpacing.xs + 2),
        Text(label, style: SsTypeScale.small.copyWith(color: c.onSurfaceVariant)),
      ],
    );
  }
}
