import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_design_system/ss_design_system.dart';

import 'core/l10n/app_localizations.dart';
import 'core/router/app_router.dart';

void main() {
  runApp(const ProviderScope(child: SurplusServedApp()));
}

class SurplusServedApp extends ConsumerWidget {
  const SurplusServedApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Surplus → Served',
      debugShowCheckedModeBanner: false,
      theme: SsTheme.light(),
      darkTheme: SsTheme.dark(),
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
