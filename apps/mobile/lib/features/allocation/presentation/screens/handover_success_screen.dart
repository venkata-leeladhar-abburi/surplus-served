import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_design_system/ss_design_system.dart';

import '../../../../core/l10n/app_localizations.dart';

class HandoverSuccessScreen extends StatelessWidget {
  const HandoverSuccessScreen({super.key, required this.donationId});

  final String donationId;

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SsSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SsIllustration(SsIllustrations.goodFoodShared, width: 200),
              const SizedBox(height: SsSpacing.xl),
              Text(l10n.receiverCollectedTitle, style: SsTypeScale.h2.copyWith(color: c.onSurface)),
              const SizedBox(height: SsSpacing.sm),
              Text(
                l10n.receiverCollectedMessage,
                textAlign: TextAlign.center,
                style: SsTypeScale.body.copyWith(color: c.onSurfaceVariant),
              ),
              const SizedBox(height: SsSpacing.xxl),
              SsButton.primary(
                label: l10n.receiverBackToFeedCta,
                expand: true,
                onPressed: () => context.goNamed('receiverFeed'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
