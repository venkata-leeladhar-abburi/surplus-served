import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_design_system/ss_design_system.dart';

import '../../../../core/l10n/app_localizations.dart';

/// §16 onboarding entry. Auto-advances — nothing here needs a tap, and food
/// on a shrinking clock shouldn't wait on a splash screen either.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) context.goNamed('roleSelect');
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: c.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SsIllustration(SsIllustrations.onboardingWelcome, width: 180),
            const SizedBox(height: SsSpacing.xl),
            Text(
              l10n.appTitle,
              style: SsTypeScale.h2.copyWith(color: c.onSurface),
            ),
            const SizedBox(height: SsSpacing.sm),
            Text(
              l10n.splashTagline,
              style: SsTypeScale.body.copyWith(color: c.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
