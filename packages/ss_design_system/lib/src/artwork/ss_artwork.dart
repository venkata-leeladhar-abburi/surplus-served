import 'package:flutter/material.dart';

import '../tokens/tokens.g.dart';
import 'ss_artwork.g.dart';

/// One piece of artwork from the design document — an illustration (§09) or a
/// brand mark (§02).
///
/// [nativeWidth] and [nativeHeight] are the real pixel dimensions of the file.
/// They matter: the design document is a flattened raster, so these crops
/// cannot be enlarged without softening. [SsIllustration] uses them to warn in
/// debug builds when a caller asks for more than the asset can give.
@immutable
class SsArtwork {
  const SsArtwork({
    required this.name,
    required this.asset,
    required this.caption,
    required this.nativeWidth,
    required this.nativeHeight,
    this.set,
  });

  final String name;

  /// Asset key, relative to the design system package.
  final String asset;

  /// Doubles as the default screen-reader description.
  final String caption;

  final int nativeWidth;
  final int nativeHeight;

  /// The §09 section this came from — `empty`, `success`, `error`, and so on.
  final String? set;

  double get aspectRatio => nativeWidth / nativeHeight;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SsArtwork && other.name == name);

  @override
  int get hashCode => name.hashCode;
}

/// Renders an illustration from the design document (§09).
///
/// ```dart
/// SsIllustration(SsIllustrations.noFoodAvailable, width: 160)
/// ```
///
/// Illustrations are artwork, not icons: they carry their own colours and do
/// not tint to the text colour. Pass an empty [semanticLabel] to mark one
/// decorative when the heading beside it already says the same thing.
class SsIllustration extends StatelessWidget {
  const SsIllustration(
    this.artwork, {
    super.key,
    this.width,
    this.height,
    this.semanticLabel,
    this.fit = BoxFit.contain,
  });

  final SsArtwork artwork;
  final double? width;
  final double? height;
  final String? semanticLabel;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final w = width ??
        (height != null ? height! * artwork.aspectRatio : artwork.nativeWidth.toDouble());
    final h = height ?? w / artwork.aspectRatio;

    assert(() {
      final ratio = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1.0;
      if (w * ratio > artwork.nativeWidth * 1.75) {
        debugPrint(
          'SsIllustration: "${artwork.name}" asked for ${w.toStringAsFixed(0)}dp '
          'at ${ratio}x but the asset is only ${artwork.nativeWidth}px wide. '
          'It will look soft — use a smaller size, or drop in a higher-resolution '
          'export over assets/${artwork.asset}.',
        );
      }
      return true;
    }());

    final image = Image.asset(
      artwork.asset,
      package: 'ss_design_system',
      width: w,
      height: h,
      fit: fit,
      filterQuality: FilterQuality.medium,
      excludeFromSemantics: true,
    );

    final label = semanticLabel ?? artwork.caption;
    if (label.isEmpty) return ExcludeSemantics(child: image);
    return Semantics(label: label, image: true, child: image);
  }
}

/// The Surplus → Served logo (§02.1).
///
/// Three approved lockups, straight from the design document. §02.9 forbids
/// recolouring, restacking or crowding the mark, so this widget exposes size
/// and nothing else — there is deliberately no colour override.
class SsLogo extends StatelessWidget {
  const SsLogo({
    super.key,
    this.variant = SsLogoVariant.horizontal,
    this.height,
    this.semanticLabel = 'Surplus → Served',
  });

  const SsLogo.horizontal({super.key, this.height, this.semanticLabel = 'Surplus → Served'})
      : variant = SsLogoVariant.horizontal;

  const SsLogo.stacked({super.key, this.height, this.semanticLabel = 'Surplus → Served'})
      : variant = SsLogoVariant.stacked;

  const SsLogo.mark({super.key, this.height, this.semanticLabel = 'Surplus → Served'})
      : variant = SsLogoVariant.mark;

  final SsLogoVariant variant;

  /// Height in logical pixels. §02.9 sets the floor at 24px; anything smaller
  /// is clamped up rather than rendered illegibly.
  final double? height;

  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final art = switch (variant) {
      SsLogoVariant.horizontal => SsBrandArt.logoHorizontal,
      SsLogoVariant.stacked => SsBrandArt.logoStacked,
      SsLogoVariant.mark => SsBrandArt.leafMark,
    };

    final h = (height ?? art.nativeHeight.toDouble()).clamp(
      SsLogoRules.minSize,
      double.infinity,
    );

    return Semantics(
      label: semanticLabel,
      image: true,
      child: Image.asset(
        art.asset,
        package: 'ss_design_system',
        height: h,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        excludeFromSemantics: true,
      ),
    );
  }
}

enum SsLogoVariant { horizontal, stacked, mark }

/// §02.9 Logo rules, encoded so they can be asserted rather than remembered.
abstract final class SsLogoRules {
  /// Minimum size, digital (§02.9). Print minimum is 10mm.
  static const double minSize = 24;

  /// Clear space on all four sides, as a multiple of the lockup's height —
  /// the document specifies the cap height of the S, which is about half.
  static const double clearSpaceRatio = 0.5;

  static const List<String> dont = [
    'Recolour the leaves or the arrow.',
    'Restack or re-space the wordmark.',
    'Crowd the mark inside its clear space.',
    'Substitute the typeface or add effects.',
    'Place the colour mark on a low-contrast photograph.',
  ];
}

/// Wraps a logo in the clear space §02.9 requires.
class SsLogoLockup extends StatelessWidget {
  const SsLogoLockup({super.key, required this.child, this.height = 40});

  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    final space = height * SsLogoRules.clearSpaceRatio;
    return Padding(
      padding: EdgeInsets.all(space.clamp(SsSpacing.sm, SsSpacing.xxl)),
      child: child,
    );
  }
}
