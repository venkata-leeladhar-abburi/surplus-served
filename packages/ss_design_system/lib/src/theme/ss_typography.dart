import 'package:flutter/material.dart';

import '../tokens/tokens.g.dart';

/// §04 Typography — Inter for the interface, Lora for display and quotes.
///
/// Both families ship as bundled assets (see `pubspec.yaml`) rather than being
/// fetched at runtime: Telugu users on weak connections must never wait on a
/// font download to read a pickup window.
abstract final class SsTypography {
  static const String primary = 'Inter';
  static const String secondary = 'Lora';

  /// Telugu fallback. Declared here so every text style picks it up via
  /// [TextStyle.fontFamilyFallback] — §14 requires full en/te parity.
  static const List<String> fallback = ['NotoSansTelugu', 'Inter'];

  static const TextStyle button = TextStyle(
    fontFamily: primary,
    fontWeight: FontWeight.w600,
    fontVariations: [FontVariation('wght', 600)],
    fontSize: 16,
    height: 1.2,
    letterSpacing: 0.1,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: primary,
    fontWeight: FontWeight.w600,
    fontVariations: [FontVariation('wght', 600)],
    fontSize: 12,
    height: 1.4,
    letterSpacing: 1.2,
  );

  static TextTheme textTheme(Color onSurface, Color onSurfaceVariant) {
    TextStyle s(TextStyle base, Color color) =>
        base.copyWith(color: color, fontFamilyFallback: fallback);

    return TextTheme(
      displayLarge: s(SsTypeScale.h1, onSurface),
      displayMedium: s(SsTypeScale.h2, onSurface),
      displaySmall: s(SsTypeScale.display, onSurface),
      headlineLarge: s(SsTypeScale.h2, onSurface),
      headlineMedium: s(SsTypeScale.h3, onSurface),
      headlineSmall: s(SsTypeScale.h4, onSurface),
      titleLarge: s(SsTypeScale.h4, onSurface),
      titleMedium: s(SsTypeScale.h5, onSurface),
      titleSmall: s(SsTypeScale.body.copyWith(fontWeight: FontWeight.w600), onSurface),
      bodyLarge: s(SsTypeScale.body, onSurface),
      bodyMedium: s(SsTypeScale.small, onSurfaceVariant),
      bodySmall: s(SsTypeScale.caption, onSurfaceVariant),
      labelLarge: s(button, onSurface),
      labelMedium: s(SsTypeScale.small, onSurfaceVariant),
      labelSmall: s(overline, onSurfaceVariant),
    );
  }
}

extension SsTextThemeX on BuildContext {
  TextTheme get ssText => Theme.of(this).textTheme;
}
