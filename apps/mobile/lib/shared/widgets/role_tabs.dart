import 'package:ss_design_system/ss_design_system.dart';

import '../../core/l10n/app_localizations.dart';
import 'role_scaffold.dart';

/// Fixed tab order for each role's bottom nav — index here must match the
/// index passed to `RoleScaffold.currentIndex` from each tab screen.
List<RoleTab> donorTabs(AppLocalizations l10n) => [
  RoleTab(icon: SsIcons.home, label: l10n.navHome, routeName: 'donorDashboard'),
  RoleTab(
    icon: SsIcons.refresh,
    label: l10n.navRecurring,
    routeName: 'donorRecurring',
  ),
  RoleTab(
    icon: SsIcons.time,
    label: l10n.navHistory,
    routeName: 'donorHistory',
  ),
  RoleTab(
    icon: SsIcons.bell,
    label: l10n.navAlerts,
    routeName: 'donorNotifications',
  ),
  RoleTab(
    icon: SsIcons.user,
    label: l10n.navProfile,
    routeName: 'donorProfile',
  ),
];

List<RoleTab> receiverTabs(AppLocalizations l10n) => [
  RoleTab(icon: SsIcons.home, label: l10n.navHome, routeName: 'receiverFeed'),
  RoleTab(
    icon: SsIcons.package,
    label: l10n.navRequests,
    routeName: 'receiverRequests',
  ),
  RoleTab(
    icon: SsIcons.time,
    label: l10n.navHistory,
    routeName: 'receiverHistory',
  ),
  RoleTab(
    icon: SsIcons.bell,
    label: l10n.navAlerts,
    routeName: 'receiverNotifications',
  ),
  RoleTab(
    icon: SsIcons.user,
    label: l10n.navProfile,
    routeName: 'receiverProfile',
  ),
];
