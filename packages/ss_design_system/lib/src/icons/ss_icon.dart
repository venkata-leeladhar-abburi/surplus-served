import 'package:flutter/material.dart';

import '../theme/ss_colors.dart';
import '../tokens/tokens.g.dart';
import 'ss_icons.g.dart';

/// One icon's geometry, in the 24 × 24 icon space (§05.2).
///
/// [outline] paths are stroked; [filled] paths are filled as a single path so
/// that an inner shape becomes a hole under the even-odd rule — unless
/// [fillNonZero] is set, in which case overlapping shapes union instead.
@immutable
class SsIconData {
  const SsIconData({
    required this.name,
    required this.outline,
    this.filled,
    this.fillNonZero = false,
  });

  final String name;
  final List<String> outline;
  final List<String>? filled;
  final bool fillNonZero;

  bool get hasFilled => filled != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SsIconData && other.name == name);

  @override
  int get hashCode => name.hashCode;
}

/// Parses the `M` / `L` / `C` / `Z` absolute-coordinate subset emitted by
/// `design/icons/geom.mjs`.
///
/// Deliberately not a general SVG parser — the generator only ever produces
/// these four commands, so supporting more would be untested surface area.
abstract final class SsIconPath {
  static final RegExp _command = RegExp(r'([MLCZ])([^MLCZ]*)');
  static final RegExp _number = RegExp(r'-?\d*\.?\d+(?:[eE][-+]?\d+)?');

  static final Map<String, Path> _cache = <String, Path>{};

  /// Builds (and caches) the [Path] for [icon]. Parsing is pure geometry, so
  /// one parse per icon per variant is enough for the life of the process.
  static Path resolve(SsIconData icon, {required bool filled}) {
    final key = '${icon.name}:${filled ? 'f' : 'o'}';
    final cached = _cache[key];
    if (cached != null) return cached;

    final subpaths = filled ? (icon.filled ?? icon.outline) : icon.outline;
    final path = Path()
      ..fillType = icon.fillNonZero ? PathFillType.nonZero : PathFillType.evenOdd;

    for (final d in subpaths) {
      _append(path, d);
    }

    _cache[key] = path;
    return path;
  }

  /// Parses a single raw path string. Used by illustrations, which share this
  /// grammar but paint each subpath with its own fill and stroke.
  static Path parse(String d, {bool nonZero = true}) {
    final key = 'raw:${nonZero ? 'nz' : 'eo'}:$d';
    final cached = _cache[key];
    if (cached != null) return cached;

    final path = Path()
      ..fillType = nonZero ? PathFillType.nonZero : PathFillType.evenOdd;
    _append(path, d);
    _cache[key] = path;
    return path;
  }

  static void _append(Path path, String d) {
    double startX = 0;
    double startY = 0;

    for (final match in _command.allMatches(d)) {
      final cmd = match.group(1)!;
      final args = _number
          .allMatches(match.group(2) ?? '')
          .map((m) => double.parse(m.group(0)!))
          .toList(growable: false);

      switch (cmd) {
        case 'M':
          for (var i = 0; i + 1 < args.length; i += 2) {
            if (i == 0) {
              path.moveTo(args[0], args[1]);
              startX = args[0];
              startY = args[1];
            } else {
              // Extra pairs after an M are implicit line-tos, per SVG.
              path.lineTo(args[i], args[i + 1]);
            }
          }
        case 'L':
          for (var i = 0; i + 1 < args.length; i += 2) {
            path.lineTo(args[i], args[i + 1]);
          }
        case 'C':
          for (var i = 0; i + 5 < args.length; i += 6) {
            path.cubicTo(
              args[i], args[i + 1],
              args[i + 2], args[i + 3],
              args[i + 4], args[i + 5],
            );
          }
        case 'Z':
          path.close();
          path.moveTo(startX, startY);
      }
    }
  }

  @visibleForTesting
  static void clearCache() => _cache.clear();
}

/// Renders an icon from the Surplus → Served set.
///
/// ```dart
/// SsIcon(SsIcons.leaf)
/// SsIcon(SsIcons.home, filled: true, size: SsIconSize.lg)
/// SsIcon(SsIcons.phone, semanticLabel: 'Call the donor')
/// ```
///
/// The whole 24-unit canvas is scaled to [size], so the 2px stroke scales with
/// it — that is what §05.6 means by "maintains visual weight" across the
/// 16 → 48 range, rather than a hairline that disappears when the icon grows.
class SsIcon extends StatelessWidget {
  const SsIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.filled = false,
    this.strokeWidth,
    this.semanticLabel,
  });

  /// Looks the icon up by name — for values that arrive as data, such as
  /// [SsStatus.iconName]. Renders nothing if the name is unknown.
  factory SsIcon.named(
    String name, {
    Key? key,
    double? size,
    Color? color,
    bool filled = false,
    String? semanticLabel,
  }) {
    return SsIcon(
      SsIcons.all[name] ?? SsIcons.help,
      key: key,
      size: size,
      color: color,
      filled: filled,
      semanticLabel: semanticLabel,
    );
  }

  final SsIconData icon;
  final double? size;
  final Color? color;

  /// Filled variants are for active states and primary actions (§05.4).
  /// Falls back to the outline when an icon has no filled form.
  final bool filled;

  /// In icon-space units. Defaults to the system's 2px stroke.
  final double? strokeWidth;

  /// Omit for purely decorative icons that sit beside a text label — a
  /// duplicate announcement is worse than none.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final resolved = size ?? iconTheme.size ?? SsIconSize.md;
    final paint = color ?? iconTheme.color ?? context.ssColors.onSurface;
    final useFilled = filled && icon.hasFilled;

    Widget child = CustomPaint(
      size: Size.square(resolved),
      isComplex: false,
      painter: _SsIconPainter(
        path: SsIconPath.resolve(icon, filled: useFilled),
        color: paint,
        filled: useFilled,
        strokeWidth: strokeWidth ?? SsIconSize.stroke,
        scale: resolved / 24.0,
      ),
    );

    // Align (not SizedBox alone) so the glyph shrink-wraps when it is free to,
    // and CENTRES when a parent forces a bigger size — an icon dropped into a
    // fixed-size circle or thumbnail otherwise paints in the top-left corner.
    child = Align(
      widthFactor: 1,
      heightFactor: 1,
      child: SizedBox.square(dimension: resolved, child: child),
    );

    if (semanticLabel != null) {
      return Semantics(label: semanticLabel, image: true, child: child);
    }
    return ExcludeSemantics(child: child);
  }
}

class _SsIconPainter extends CustomPainter {
  const _SsIconPainter({
    required this.path,
    required this.color,
    required this.filled,
    required this.strokeWidth,
    required this.scale,
  });

  final Path path;
  final Color color;
  final bool filled;
  final double strokeWidth;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(scale);

    final paint = Paint()
      ..color = color
      ..isAntiAlias = true;

    if (filled) {
      paint.style = PaintingStyle.fill;
    } else {
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
    }

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SsIconPainter old) =>
      old.path != path ||
      old.color != color ||
      old.filled != filled ||
      old.strokeWidth != strokeWidth ||
      old.scale != scale;
}
