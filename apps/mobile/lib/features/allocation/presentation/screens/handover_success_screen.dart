import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_design_system/ss_design_system.dart';

class HandoverSuccessScreen extends StatelessWidget {
  const HandoverSuccessScreen({super.key, required this.donationId});

  final String donationId;

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;
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
              Text('Collected', style: SsTypeScale.h2.copyWith(color: c.onSurface)),
              const SizedBox(height: SsSpacing.sm),
              Text(
                'Good food, kept moving. Thank you.',
                textAlign: TextAlign.center,
                style: SsTypeScale.body.copyWith(color: c.onSurfaceVariant),
              ),
              const SizedBox(height: SsSpacing.xxl),
              SsButton.primary(
                label: 'Back to feed',
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
