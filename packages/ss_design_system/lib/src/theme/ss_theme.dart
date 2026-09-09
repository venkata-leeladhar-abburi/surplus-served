import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/tokens.g.dart';
import 'ss_colors.dart';
import 'ss_typography.dart';

/// Builds the app-wide [ThemeData] from design tokens.
///
/// Everything here is derived — no literal colours, sizes or radii. If a value
/// looks wrong, fix `design/tokens/tokens.json` and regenerate.
abstract final class SsTheme {
  static ThemeData light() => _build(SsColors.light);
  static ThemeData dark() => _build(SsColors.dark);

  static ThemeData _build(SsColors c) {
    final isLight = c.brightness == Brightness.light;
    final text = SsTypography.textTheme(c.onSurface, c.onSurfaceVariant);

    return ThemeData(
      useMaterial3: true,
      brightness: c.brightness,
      scaffoldBackgroundColor: c.background,
      canvasColor: c.background,
      fontFamily: SsTypography.primary,
      extensions: <ThemeExtension<dynamic>>[c],
      visualDensity: VisualDensity.standard,
      splashFactory: InkSparkle.splashFactory,

      colorScheme: ColorScheme(
        brightness: c.brightness,
        primary: c.primary,
        onPrimary: c.onPrimary,
        primaryContainer: c.primaryContainer,
        onPrimaryContainer: c.onPrimaryContainer,
        secondary: c.secondary,
        onSecondary: c.onSecondary,
        secondaryContainer: c.primaryContainer,
        onSecondaryContainer: c.onPrimaryContainer,
        tertiary: c.accent,
        onTertiary: c.onAccent,
        tertiaryContainer: c.warningContainer,
        onTertiaryContainer: c.onSurface,
        error: c.error,
        onError: Colors.white,
        errorContainer: c.errorContainer,
        onErrorContainer: c.onSurface,
        surface: c.surface,
        onSurface: c.onSurface,
        onSurfaceVariant: c.onSurfaceVariant,
        outline: c.border,
        outlineVariant: c.border,
        shadow: SsPalette.ink,
        scrim: SsPalette.ink,
        inverseSurface: isLight ? SsPalette.green900 : SsPalette.surface,
        onInverseSurface: isLight ? SsPalette.white : SsPalette.ink,
        inversePrimary: isLight ? SsPalette.green300 : SsPalette.leafGreen,
      ),

      textTheme: text,
      primaryTextTheme: text,

      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        foregroundColor: c.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: SsTypeScale.h5.copyWith(color: c.onSurface),
        systemOverlayStyle:
            isLight ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
      ),

      // §06.1 Buttons — Primary
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((s) {
            if (s.contains(WidgetState.disabled)) return c.surfaceAlt;
            if (s.contains(WidgetState.pressed)) return SsPalette.green900;
            if (s.contains(WidgetState.hovered)) return c.primaryContainer;
            return c.primary;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((s) {
            if (s.contains(WidgetState.disabled)) return c.muted;
            if (s.contains(WidgetState.hovered)) return c.onPrimaryContainer;
            return c.onPrimary;
          }),
          overlayColor: WidgetStateProperty.all(Colors.white24),
          elevation: WidgetStateProperty.all(0),
          minimumSize: WidgetStateProperty.all(
            const Size(double.minPositive, SsA11y.minTapTarget + 4),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(
              horizontal: SsSpacing.xl,
              vertical: SsSpacing.md,
            ),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(SsRadius.md)),
          ),
          textStyle: WidgetStateProperty.all(SsTypography.button),
        ),
      ),

      // §06.1 Buttons — Secondary (outlined)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((s) {
            if (s.contains(WidgetState.hovered)) return c.primaryContainer;
            return c.surface;
          }),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.disabled) ? c.muted : c.primary,
          ),
          side: WidgetStateProperty.resolveWith(
            (s) => BorderSide(
              color: s.contains(WidgetState.disabled) ? c.border : c.primary,
              width: 1.5,
            ),
          ),
          minimumSize: WidgetStateProperty.all(
            const Size(double.minPositive, SsA11y.minTapTarget + 4),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(
              horizontal: SsSpacing.xl,
              vertical: SsSpacing.md,
            ),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(SsRadius.md)),
          ),
          textStyle: WidgetStateProperty.all(SsTypography.button),
        ),
      ),

      // §06.1 Buttons — Tertiary (text)
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.disabled) ? c.muted : c.primary,
          ),
          minimumSize: WidgetStateProperty.all(
            const Size(double.minPositive, SsA11y.minTapTarget),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: SsSpacing.md),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(SsRadius.sm)),
          ),
          textStyle: WidgetStateProperty.all(SsTypography.button),
        ),
      ),

      // §06.2 Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        hintStyle: SsTypeScale.body.copyWith(color: c.muted),
        labelStyle: SsTypeScale.small.copyWith(color: c.onSurfaceVariant),
        floatingLabelStyle: SsTypeScale.small.copyWith(color: c.primary),
        errorStyle: SsTypeScale.caption.copyWith(color: c.error),
        prefixIconColor: WidgetStateColor.resolveWith(
          (s) => s.contains(WidgetState.focused) ? c.primary : c.muted,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SsSpacing.lg,
          vertical: SsSpacing.md + 2,
        ),
        constraints: const BoxConstraints(minHeight: SsA11y.minTapTarget + 4),
        border: _fieldBorder(c.border),
        enabledBorder: _fieldBorder(c.border),
        focusedBorder: _fieldBorder(c.primary, width: 1.5),
        errorBorder: _fieldBorder(c.error),
        focusedErrorBorder: _fieldBorder(c.error, width: 1.5),
        disabledBorder: _fieldBorder(c.border),
      ),

      // §06.3 Cards
      cardTheme: CardThemeData(
        color: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: c.border),
          borderRadius: BorderRadius.circular(SsRadius.lg),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // §06.4 Badges & tags
      chipTheme: ChipThemeData(
        backgroundColor: c.surfaceAlt,
        selectedColor: c.primaryContainer,
        disabledColor: c.surfaceAlt,
        side: BorderSide(color: c.border),
        labelStyle: SsTypeScale.small.copyWith(color: c.onSurface),
        secondaryLabelStyle: SsTypeScale.small.copyWith(color: c.onPrimaryContainer),
        padding: const EdgeInsets.symmetric(
          horizontal: SsSpacing.md,
          vertical: SsSpacing.sm,
        ),
        shape: const StadiumBorder(),
        showCheckmark: false,
      ),

      // §06.5 Navigation — bottom nav (mobile)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: c.primaryContainer,
        indicatorShape: const StadiumBorder(),
        height: 68,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => SsTypeScale.caption.copyWith(
            color: s.contains(WidgetState.selected) ? c.primary : c.onSurfaceVariant,
            fontWeight: s.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w400,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            size: SsIconSize.md,
            color: s.contains(WidgetState.selected) ? c.primary : c.onSurfaceVariant,
          ),
        ),
      ),

      // §06.7 Modals
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SsRadius.xl),
        ),
        titleTextStyle: SsTypeScale.h4.copyWith(color: c.onSurface),
        contentTextStyle: SsTypeScale.body.copyWith(color: c.onSurfaceVariant),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        showDragHandle: true,
        dragHandleColor: c.border,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(SsRadius.xl)),
        ),
      ),

      // §06.8 Selection controls
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? Colors.white : c.surface,
        ),
        trackColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.disabled)) return c.border;
          return s.contains(WidgetState.selected) ? c.primary : c.muted;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.disabled)) return c.surfaceAlt;
          return s.contains(WidgetState.selected) ? c.primary : Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(c.onPrimary),
        side: BorderSide(color: c.border, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SsRadius.xs),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? c.primary : c.border,
        ),
      ),

      // §06.9 / §07.7 Progress & sliders
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.primary,
        linearTrackColor: c.surfaceAlt,
        circularTrackColor: c.surfaceAlt,
        linearMinHeight: 8,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: c.primary,
        inactiveTrackColor: c.surfaceAlt,
        thumbColor: c.primary,
        overlayColor: c.primary.withValues(alpha: 0.12),
        trackHeight: 6,
      ),

      // §07.4 Tabs
      tabBarTheme: TabBarThemeData(
        labelColor: c.primary,
        unselectedLabelColor: c.onSurfaceVariant,
        labelStyle: SsTypeScale.body.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: SsTypeScale.body,
        indicatorColor: c.primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: c.border,
      ),

      // §07.14 Tooltips
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(SsRadius.md),
          border: Border.all(color: c.border),
          boxShadow: SsShadows.md,
        ),
        textStyle: SsTypeScale.small.copyWith(color: c.onSurface),
        padding: const EdgeInsets.symmetric(
          horizontal: SsSpacing.md,
          vertical: SsSpacing.sm,
        ),
      ),

      dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),

      iconTheme: IconThemeData(color: c.onSurface, size: SsIconSize.md),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: isLight ? SsPalette.green900 : c.surfaceAlt,
        contentTextStyle: SsTypeScale.small.copyWith(color: SsPalette.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SsRadius.md),
        ),
      ),

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static OutlineInputBorder _fieldBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(SsRadius.md),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
