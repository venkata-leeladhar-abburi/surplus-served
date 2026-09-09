// GENERATED FILE — DO NOT EDIT.
// Source: design/tokens/tokens.json
// Design System v1.0.0
// Regenerate: node design/tools/generate.mjs

// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

/// Raw colour primitives. Prefer [SsColors] via `Theme.of(context).extension`
/// in feature code; reach for these only inside the design system itself.
abstract final class SsPalette {
  static const leafGreen = Color(0xFF1F6B4A);
  static const sageGreen = Color(0xFF4CAF7A);
  static const harvestOrange = Color(0xFFE39A1F);
  static const tomatoRed = Color(0xFFC2402B);
  static const sunriseYellow = Color(0xFFF6C453);
  static const earthBrown = Color(0xFF6B4F3B);
  static const green50 = Color(0xFFF4FAF7);
  static const green100 = Color(0xFFE6F3EC);
  static const green300 = Color(0xFFA7D5B9);
  static const green500 = Color(0xFF4CAF7A);
  static const green700 = Color(0xFF1F6B4A);
  static const green900 = Color(0xFF0E3D2C);
  static const ink = Color(0xFF15211B);
  static const inkSoft = Color(0xFF4A574F);
  static const surface = Color(0xFFFAFBF7);
  static const surfaceAlt = Color(0xFFF2F4EE);
  static const border = Color(0xFFD9E1D6);
  static const muted = Color(0xFFA3B1A7);
  static const white = Color(0xFFFFFFFF);
  static const success = Color(0xFF16A34A);
  static const onSuccessContainer = Color(0xFF107D38);
  static const error = Color(0xFFDC2626);
  static const onErrorContainer = Color(0xFFD32424);
  static const warning = Color(0xFFD97706);
  static const onWarningContainer = Color(0xFFA95C04);
  static const info = Color(0xFF2563EB);
  static const onInfoContainer = Color(0xFF2563EB);
  static const focus = Color(0xFF7C3AED);
  static const onFocusContainer = Color(0xFF7C3AED);
}

abstract final class SsGradients {
  static const nature = [Color(0xFF1F6B4A), Color(0xFF4CAF7A)];
  static const sunrise = [Color(0xFFE39A1F), Color(0xFFF6C453)];
}

abstract final class SsSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;
  static const double huge = 56.0;
  static const double mega = 72.0;
  static const double screenPadding = 16.0;
  static const double cardPadding = 16.0;
  static const double sectionGap = 24.0;
}

abstract final class SsRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double pill = 999.0;
}

abstract final class SsIconSize {
  static const double stroke = 2.0;
  static const double xs = 16.0;
  static const double sm = 20.0;
  static const double md = 24.0;
  static const double lg = 32.0;
  static const double xl = 48.0;
}

abstract final class SsDuration {
  static const instant = Duration(milliseconds: 100);
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 400);
  static const deliberate = Duration(milliseconds: 600);
}

abstract final class SsShadows {
  static const List<BoxShadow> none = <BoxShadow>[];
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0D15211B),
      offset: Offset(0, 1.0),
      blurRadius: 2.0,
      spreadRadius: 0.0,
    ),
  ];
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x0F15211B),
      offset: Offset(0, 2.0),
      blurRadius: 8.0,
      spreadRadius: 0.0,
    ),
  ];
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x1415211B),
      offset: Offset(0, 6.0),
      blurRadius: 20.0,
      spreadRadius: 0.0,
    ),
  ];
  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x1A15211B),
      offset: Offset(0, 12.0),
      blurRadius: 32.0,
      spreadRadius: 0.0,
    ),
  ];
}

abstract final class SsTypeScale {
  static const h1 = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w700,
    fontVariations: [FontVariation('wght', 700.0)],
    fontSize: 56.0,
    height: 1.20,
  );

  static const h2 = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w600,
    fontVariations: [FontVariation('wght', 600.0)],
    fontSize: 40.0,
    height: 1.20,
  );

  static const h3 = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w600,
    fontVariations: [FontVariation('wght', 600.0)],
    fontSize: 32.0,
    height: 1.20,
  );

  static const h4 = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w500,
    fontVariations: [FontVariation('wght', 500.0)],
    fontSize: 24.0,
    height: 1.30,
  );

  static const h5 = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w500,
    fontVariations: [FontVariation('wght', 500.0)],
    fontSize: 20.0,
    height: 1.40,
  );

  static const body = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w400,
    fontVariations: [FontVariation('wght', 400.0)],
    fontSize: 16.0,
    height: 1.60,
  );

  static const small = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w400,
    fontVariations: [FontVariation('wght', 400.0)],
    fontSize: 14.0,
    height: 1.60,
  );

  static const caption = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w400,
    fontVariations: [FontVariation('wght', 400.0)],
    fontSize: 12.0,
    height: 1.60,
  );

  static const display = TextStyle(
    fontFamily: 'Lora',
    fontWeight: FontWeight.w500,
    fontVariations: [FontVariation('wght', 500.0)],
    fontSize: 40.0,
    height: 1.25,
  );

  static const quote = TextStyle(
    fontFamily: 'Lora',
    fontWeight: FontWeight.w400,
    fontVariations: [FontVariation('wght', 400.0)],
    fontSize: 20.0,
    height: 1.50,
    fontStyle: FontStyle.italic,
  );
}

abstract final class SsA11y {
  static const double minTapTarget = 44.0;
  static const double textScaleMax = 2.0;
  static const double focusRingWidth = 2.0;
  static const double focusRingOffset = 2.0;
  static const Color focusRingColor = Color(0xFF7C3AED);
}

abstract final class SsBreakpoints {
  static const double xs = 0.0;
  static const double sm = 600.0;
  static const double md = 905.0;
  static const double lg = 1240.0;
  static const double xl = 1440.0;
}

/// Donation lifecycle status → colour, surface, icon name, English label.
/// Colour is never the only signal: always render the icon and label too.
enum SsStatus {
  draft(Color(0xFFA3B1A7), Color(0xFF68716A), Color(0xFFF2F4EE), 'edit', 'Draft'),
  pendingCheck(Color(0xFFD97706), Color(0xFFA95C04), Color(0xFFFDF3E2), 'time', 'Under review'),
  live(Color(0xFF16A34A), Color(0xFF107D38), Color(0xFFE6F3EC), 'check', 'Live'),
  allocated(Color(0xFF2563EB), Color(0xFF2563EB), Color(0xFFEAF0FE), 'user', 'Allocated'),
  collected(Color(0xFF1F6B4A), Color(0xFF1F6B4A), Color(0xFFE6F3EC), 'leaf', 'Collected'),
  reallocated(Color(0xFFD97706), Color(0xFFA95C04), Color(0xFFFDF3E2), 'refresh', 'Reallocated'),
  unfulfilled(Color(0xFFA3B1A7), Color(0xFF68716A), Color(0xFFF2F4EE), 'time', 'Unfulfilled'),
  cancelled(Color(0xFFDC2626), Color(0xFFD32424), Color(0xFFFDECEA), 'close', 'Cancelled'),
  rejected(Color(0xFFDC2626), Color(0xFFD32424), Color(0xFFFDECEA), 'alert', 'Rejected'),
  urgent(Color(0xFFC2402B), Color(0xFFC2402B), Color(0xFFFDECEA), 'alert', 'Urgent');

  const SsStatus(this.color, this.text, this.surface, this.iconName, this.labelEn);

  /// Brand hue — for fills, dots and large shapes.
  final Color color;

  /// AA-verified label/icon tone on [surface] (>= 4.5:1).
  final Color text;

  final Color surface;
  final String iconName;
  final String labelEn;
}
