import 'package:flutter/material.dart';

import '../tokens/tokens.g.dart';

/// Semantic colour roles for Surplus → Served.
///
/// Feature code should read colours from here — never from [SsPalette]
/// directly — so that a light/dark or seasonal variant only has to be
/// defined once, in [SsColors.light] / [SsColors.dark].
@immutable
class SsColors extends ThemeExtension<SsColors> {
  const SsColors({
    required this.brightness,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.accent,
    required this.onAccent,
    required this.alert,
    required this.onAlert,
    required this.highlight,
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.border,
    required this.muted,
    required this.success,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.error,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.warning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.info,
    required this.infoContainer,
    required this.onInfoContainer,
    required this.focus,
    required this.natureGradient,
    required this.sunriseGradient,
  });

  final Brightness brightness;

  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;

  final Color secondary;
  final Color onSecondary;

  final Color accent;
  final Color onAccent;

  final Color alert;
  final Color onAlert;

  final Color highlight;

  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color border;
  final Color muted;

  final Color success;
  final Color successContainer;

  /// AA-verified icon/text tone on [successContainer]. Same pattern for the
  /// other three: the saturated brand hue is a fill colour, not a text colour.
  final Color onSuccessContainer;

  final Color error;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color warning;
  final Color warningContainer;
  final Color onWarningContainer;
  final Color info;
  final Color infoContainer;
  final Color onInfoContainer;
  final Color focus;

  final List<Color> natureGradient;
  final List<Color> sunriseGradient;

  static const SsColors light = SsColors(
    brightness: Brightness.light,
    primary: SsPalette.leafGreen,
    onPrimary: SsPalette.white,
    primaryContainer: SsPalette.green100,
    onPrimaryContainer: SsPalette.green900,
    secondary: SsPalette.sageGreen,
    onSecondary: SsPalette.white,
    accent: SsPalette.harvestOrange,
    onAccent: SsPalette.ink,
    alert: SsPalette.tomatoRed,
    onAlert: SsPalette.white,
    highlight: SsPalette.sunriseYellow,
    background: SsPalette.surface,
    surface: SsPalette.white,
    surfaceAlt: SsPalette.surfaceAlt,
    onSurface: SsPalette.ink,
    onSurfaceVariant: SsPalette.inkSoft,
    border: SsPalette.border,
    muted: SsPalette.muted,
    success: SsPalette.success,
    successContainer: Color(0xFFE6F3EC),
    onSuccessContainer: SsPalette.onSuccessContainer,
    error: SsPalette.error,
    errorContainer: Color(0xFFFDECEA),
    onErrorContainer: SsPalette.onErrorContainer,
    warning: SsPalette.warning,
    warningContainer: Color(0xFFFDF3E2),
    onWarningContainer: SsPalette.onWarningContainer,
    info: SsPalette.info,
    infoContainer: Color(0xFFEAF0FE),
    onInfoContainer: SsPalette.onInfoContainer,
    focus: SsPalette.focus,
    natureGradient: SsGradients.nature,
    sunriseGradient: SsGradients.sunrise,
  );

  /// Dark variant. The design system is authored light-first; these values
  /// keep the same semantic roles while meeting the WCAG 2.2 AA contrast
  /// floor the system commits to (§10 "Test in both light and dark").
  static const SsColors dark = SsColors(
    brightness: Brightness.dark,
    primary: SsPalette.green500,
    onPrimary: Color(0xFF06210F),
    primaryContainer: Color(0xFF14352A),
    onPrimaryContainer: SsPalette.green300,
    secondary: SsPalette.green300,
    onSecondary: Color(0xFF06210F),
    accent: SsPalette.sunriseYellow,
    onAccent: Color(0xFF231703),
    alert: Color(0xFFE9705A),
    onAlert: Color(0xFF2A0B06),
    highlight: SsPalette.sunriseYellow,
    background: Color(0xFF0D1512),
    surface: Color(0xFF141F1A),
    surfaceAlt: Color(0xFF1B2721),
    onSurface: Color(0xFFEAF1EC),
    onSurfaceVariant: Color(0xFFAFBDB4),
    border: Color(0xFF2C3A33),
    muted: Color(0xFF7C8B82),
    success: Color(0xFF4ADE80),
    successContainer: Color(0xFF10301E),
    onSuccessContainer: Color(0xFF4ADE80),
    error: Color(0xFFF87171),
    errorContainer: Color(0xFF3A1513),
    onErrorContainer: Color(0xFFF87171),
    warning: Color(0xFFFBBF24),
    warningContainer: Color(0xFF33240A),
    onWarningContainer: Color(0xFFFBBF24),
    info: Color(0xFF60A5FA),
    infoContainer: Color(0xFF10203D),
    onInfoContainer: Color(0xFF60A5FA),
    focus: Color(0xFFA78BFA),
    natureGradient: [Color(0xFF14352A), SsPalette.green500],
    sunriseGradient: [Color(0xFF8A5C10), SsPalette.sunriseYellow],
  );

  /// Resolves the status colour pair for a donation lifecycle state.
  /// Callers must still render the icon and label — never colour alone.
  ({Color fg, Color bg}) statusColors(SsStatus status) {
    if (brightness == Brightness.light) {
      // `text` is the AA-verified tone for this status on its own surface;
      // `color` is the brand hue, reserved for fills and dots.
      return (fg: status.text, bg: status.surface);
    }
    // Dark tints the chip with the status hue, so the light pair proves
    // nothing here — `dark` is the tone verified against that tinted ground.
    return (
      fg: status.dark,
      bg: Color.alphaBlend(status.color.withValues(alpha: 0.18), surface),
    );
  }

  @override
  SsColors copyWith({
    Brightness? brightness,
    Color? primary,
    Color? onPrimary,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? secondary,
    Color? onSecondary,
    Color? accent,
    Color? onAccent,
    Color? alert,
    Color? onAlert,
    Color? highlight,
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? onSurface,
    Color? onSurfaceVariant,
    Color? border,
    Color? muted,
    Color? success,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? error,
    Color? errorContainer,
    Color? onErrorContainer,
    Color? warning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? info,
    Color? infoContainer,
    Color? onInfoContainer,
    Color? focus,
    List<Color>? natureGradient,
    List<Color>? sunriseGradient,
  }) {
    return SsColors(
      brightness: brightness ?? this.brightness,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
      secondary: secondary ?? this.secondary,
      onSecondary: onSecondary ?? this.onSecondary,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      alert: alert ?? this.alert,
      onAlert: onAlert ?? this.onAlert,
      highlight: highlight ?? this.highlight,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      border: border ?? this.border,
      muted: muted ?? this.muted,
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      error: error ?? this.error,
      errorContainer: errorContainer ?? this.errorContainer,
      onErrorContainer: onErrorContainer ?? this.onErrorContainer,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      info: info ?? this.info,
      infoContainer: infoContainer ?? this.infoContainer,
      onInfoContainer: onInfoContainer ?? this.onInfoContainer,
      focus: focus ?? this.focus,
      natureGradient: natureGradient ?? this.natureGradient,
      sunriseGradient: sunriseGradient ?? this.sunriseGradient,
    );
  }

  @override
  SsColors lerp(ThemeExtension<SsColors>? other, double t) {
    if (other is! SsColors) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    List<Color> g(List<Color> a, List<Color> b) =>
        [for (var i = 0; i < a.length; i++) c(a[i], b[i])];
    return SsColors(
      brightness: t < 0.5 ? brightness : other.brightness,
      primary: c(primary, other.primary),
      onPrimary: c(onPrimary, other.onPrimary),
      primaryContainer: c(primaryContainer, other.primaryContainer),
      onPrimaryContainer: c(onPrimaryContainer, other.onPrimaryContainer),
      secondary: c(secondary, other.secondary),
      onSecondary: c(onSecondary, other.onSecondary),
      accent: c(accent, other.accent),
      onAccent: c(onAccent, other.onAccent),
      alert: c(alert, other.alert),
      onAlert: c(onAlert, other.onAlert),
      highlight: c(highlight, other.highlight),
      background: c(background, other.background),
      surface: c(surface, other.surface),
      surfaceAlt: c(surfaceAlt, other.surfaceAlt),
      onSurface: c(onSurface, other.onSurface),
      onSurfaceVariant: c(onSurfaceVariant, other.onSurfaceVariant),
      border: c(border, other.border),
      muted: c(muted, other.muted),
      success: c(success, other.success),
      successContainer: c(successContainer, other.successContainer),
      onSuccessContainer: c(onSuccessContainer, other.onSuccessContainer),
      error: c(error, other.error),
      errorContainer: c(errorContainer, other.errorContainer),
      onErrorContainer: c(onErrorContainer, other.onErrorContainer),
      warning: c(warning, other.warning),
      warningContainer: c(warningContainer, other.warningContainer),
      onWarningContainer: c(onWarningContainer, other.onWarningContainer),
      info: c(info, other.info),
      infoContainer: c(infoContainer, other.infoContainer),
      onInfoContainer: c(onInfoContainer, other.onInfoContainer),
      focus: c(focus, other.focus),
      natureGradient: g(natureGradient, other.natureGradient),
      sunriseGradient: g(sunriseGradient, other.sunriseGradient),
    );
  }
}

extension SsColorsX on BuildContext {
  /// `context.ssColors.primary`
  SsColors get ssColors => Theme.of(this).extension<SsColors>()!;
}
