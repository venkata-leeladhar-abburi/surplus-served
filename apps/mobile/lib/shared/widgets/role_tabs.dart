import 'package:ss_design_system/ss_design_system.dart';

import 'role_scaffold.dart';

/// Fixed tab order for each role's bottom nav — index here must match the
/// index passed to `RoleScaffold.currentIndex` from each tab screen.
const donorTabs = [
  RoleTab(icon: SsIcons.home, label: 'Home', routeName: 'donorDashboard'),
  RoleTab(icon: SsIcons.refresh, label: 'Recurring', routeName: 'donorRecurring'),
  RoleTab(icon: SsIcons.time, label: 'History', routeName: 'donorHistory'),
  RoleTab(icon: SsIcons.bell, label: 'Alerts', routeName: 'donorNotifications'),
  RoleTab(icon: SsIcons.user, label: 'Profile', routeName: 'donorProfile'),
];

const receiverTabs = [
  RoleTab(icon: SsIcons.home, label: 'Home', routeName: 'receiverFeed'),
  RoleTab(icon: SsIcons.package, label: 'Requests', routeName: 'receiverRequests'),
  RoleTab(icon: SsIcons.time, label: 'History', routeName: 'receiverHistory'),
  RoleTab(icon: SsIcons.bell, label: 'Alerts', routeName: 'receiverNotifications'),
  RoleTab(icon: SsIcons.user, label: 'Profile', routeName: 'receiverProfile'),
];
