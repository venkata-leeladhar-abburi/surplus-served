import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ss_design_system/ss_design_system.dart';
import 'package:surplus_served_mobile/core/l10n/app_localizations.dart';
import 'package:surplus_served_mobile/features/auth/presentation/screens/role_select_screen.dart';

/// Guards the whole point of wiring localizations: a screen actually reads
/// through `AppLocalizations` and renders the Telugu string, not just that
/// the key compiles. `te.arb` full parity (§14) would be silently worthless
/// if no widget ever called it.
void main() {
  testWidgets('RoleSelectScreen renders Telugu text under the te locale', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: SsTheme.light(),
        locale: const Locale('te'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const RoleSelectScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // The Telugu string for "I have food to give" — proves the screen is
    // actually calling AppLocalizations.of(context), not a hardcoded English
    // literal that happens to still compile.
    expect(find.text('నా వద్ద ఆహారం ఉంది'), findsOneWidget);
    // English must not leak through when the locale is Telugu.
    expect(find.text('I have food to give'), findsNothing);
  });

  testWidgets('RoleSelectScreen renders English text under the en locale', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: SsTheme.light(),
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const RoleSelectScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('I have food to give'), findsOneWidget);
    expect(find.text('I run a verified NGO'), findsOneWidget);
  });
}
