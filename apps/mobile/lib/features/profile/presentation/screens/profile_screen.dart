import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_design_system/ss_design_system.dart';

import '../../../../core/providers.dart';
import '../../../../shared/widgets/role_scaffold.dart';
import '../../../../shared/widgets/role_tabs.dart';
import '../../../auth/domain/user_role.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.ssColors;
    final session = ref.watch(sessionProvider);
    final isDonor = session?.role == UserRole.donor;

    return RoleScaffold(
      currentIndex: 4,
      tabs: isDonor ? donorTabs : receiverTabs,
      appBarTitle: 'Profile',
      body: Padding(
        padding: const EdgeInsets.all(SsSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                SsAvatar(name: session?.name ?? '', size: 56, verified: !isDonor),
                const SizedBox(width: SsSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(session?.name ?? '', style: SsTypeScale.h4.copyWith(color: c.onSurface)),
                      const SizedBox(height: 2),
                      Text(session?.phone ?? '',
                          style: SsTypeScale.small.copyWith(color: c.onSurfaceVariant)),
                    ],
                  ),
                ),
                if (isDonor)
                  SsTag(label: 'Donor', icon: SsIcons.donate, tone: SsTagTone.positive)
                else
                  SsTag(label: 'Verified NGO', icon: SsIcons.verified, tone: SsTagTone.info),
              ],
            ),
            const SizedBox(height: SsSpacing.xxl),
            SsListTile(
              title: 'Language',
              subtitle: 'English',
              leading: SsIcon(SsIcons.settings, color: c.onSurfaceVariant),
            ),
            SsListTile(
              title: 'Help & support',
              leading: SsIcon(SsIcons.help, color: c.onSurfaceVariant),
            ),
            const SizedBox(height: SsSpacing.xxl),
            SsButton.danger(
              label: 'Sign out',
              expand: true,
              icon: SsIcons.logout,
              onPressed: () => ref.read(sessionProvider.notifier).signOut(),
            ),
          ],
        ),
      ),
    );
  }
}
