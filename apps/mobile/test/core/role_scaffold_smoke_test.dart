import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ss_design_system/ss_design_system.dart';
import 'package:surplus_served_mobile/core/l10n/app_localizations.dart';
import 'package:surplus_served_mobile/shared/widgets/role_scaffold.dart';

void main() {
  testWidgets('RoleScaffold (and its ConnectivityBanner) renders without a connectivity plugin mock', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: SsTheme.light(),
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: RoleScaffold(
            currentIndex: 0,
            tabs: const [RoleTab(icon: SsIcons.home, label: 'Home', routeName: 'x')],
            body: const Text('body'),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('body'), findsOneWidget);
  });
}
