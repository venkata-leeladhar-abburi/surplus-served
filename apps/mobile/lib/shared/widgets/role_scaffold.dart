import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_design_system/ss_design_system.dart';

import 'connectivity_banner.dart';

/// One tab of a role's bottom nav — the label doubles as the a11y label,
/// per `SsBottomNav`'s own contract.
class RoleTab {
  const RoleTab({
    required this.icon,
    required this.label,
    required this.routeName,
  });

  final SsIconData icon;
  final String label;
  final String routeName;
}

/// Wraps a tab's screen body with the §06.5 bottom nav, shared by donor and
/// receiver shells so a new tab is one entry in a list, not a new Scaffold.
class RoleScaffold extends ConsumerWidget {
  const RoleScaffold({
    super.key,
    required this.currentIndex,
    required this.tabs,
    required this.body,
    this.appBarTitle,
    this.appBarActions,
    this.floatingActionButton,
  });

  final int currentIndex;
  final List<RoleTab> tabs;
  final Widget body;
  final String? appBarTitle;
  final List<Widget>? appBarActions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.ssColors;
    return Scaffold(
      backgroundColor: c.background,
      appBar: appBarTitle == null
          ? null
          : AppBar(
              backgroundColor: c.background,
              elevation: 0,
              title: Text(
                appBarTitle!,
                style: SsTypeScale.h4.copyWith(color: c.onSurface),
              ),
              actions: appBarActions,
            ),
      body: Column(
        children: [
          const ConnectivityBanner(),
          Expanded(child: body),
        ],
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: SsBottomNav(
        currentIndex: currentIndex,
        destinations: [
          for (final t in tabs) SsNavDestination(icon: t.icon, label: t.label),
        ],
        onSelected: (i) {
          if (i != currentIndex) context.goNamed(tabs[i].routeName);
        },
      ),
    );
  }
}
