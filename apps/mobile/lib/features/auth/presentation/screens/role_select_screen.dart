import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_design_system/ss_design_system.dart';

import '../../domain/user_role.dart';

/// Role picked before authentication, per scope §16: three roles only —
/// Donor, Receiver (verified NGO), Admin — no Volunteer.
class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SsSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text(
                'How will you use\nSurplus → Served?',
                style: SsTypeScale.h2.copyWith(color: c.onSurface),
              ),
              const SizedBox(height: SsSpacing.xxl),
              _RoleCard(
                illustration: SsIllustrations.roleDonor,
                title: 'I have food to give',
                subtitle: 'Restaurants, caterers, event kitchens',
                onTap: () => context.pushNamed('phone', extra: UserRole.donor),
              ),
              const SizedBox(height: SsSpacing.lg),
              _RoleCard(
                illustration: SsIllustrations.roleReceiver,
                title: 'I run a verified NGO',
                subtitle: 'Collect surplus food for people who need it',
                onTap: () => context.pushNamed('phone', extra: UserRole.receiver),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.illustration,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final SsArtwork illustration;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;
    return Semantics(
      button: true,
      label: '$title. $subtitle',
      child: Material(
        color: c.surface,
        borderRadius: BorderRadius.circular(SsRadius.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(SsRadius.lg),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(SsSpacing.lg),
            decoration: BoxDecoration(
              border: Border.all(color: c.border),
              borderRadius: BorderRadius.circular(SsRadius.lg),
            ),
            child: Row(
              children: [
                SsIllustration(illustration, width: 56),
                const SizedBox(width: SsSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: SsTypeScale.h4.copyWith(color: c.onSurface)),
                      const SizedBox(height: 2),
                      Text(subtitle,
                          style: SsTypeScale.small.copyWith(color: c.onSurfaceVariant)),
                    ],
                  ),
                ),
                SsIcon(SsIcons.chevronRight, color: c.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
