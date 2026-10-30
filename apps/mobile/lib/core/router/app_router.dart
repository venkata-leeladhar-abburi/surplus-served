import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/user_role.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/phone_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/role_select_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/allocation/presentation/screens/enter_pickup_code_screen.dart';
import '../../features/allocation/presentation/screens/handover_success_screen.dart';
import '../../features/discovery/presentation/screens/donation_detail_screen.dart';
import '../../features/discovery/presentation/screens/receiver_feed_screen.dart';
import '../../features/discovery/presentation/screens/my_requests_screen.dart';
import '../../features/donation/presentation/screens/create_donation_screen.dart';
import '../../features/donation/presentation/screens/donor_dashboard_screen.dart';
import '../../features/donation/presentation/screens/donor_donation_detail_screen.dart';
import '../../features/history/presentation/screens/donor_history_screen.dart';
import '../../features/history/presentation/screens/receiver_history_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/recurring/presentation/screens/recurring_templates_screen.dart';
import '../providers.dart';

/// Route names — used instead of raw path strings anywhere a screen needs
/// to navigate, so a path typo is a compile error, not a runtime 404.
abstract final class AppRoute {
  static const splash = 'splash';
  static const roleSelect = 'roleSelect';
  static const phone = 'phone';
  static const otp = 'otp';

  static const donorDashboard = 'donorDashboard';
  static const donorCreate = 'donorCreate';
  static const donorDonationDetail = 'donorDonationDetail';
  static const donorRecurring = 'donorRecurring';
  static const donorHistory = 'donorHistory';
  static const donorNotifications = 'donorNotifications';
  static const donorProfile = 'donorProfile';

  static const receiverFeed = 'receiverFeed';
  static const receiverDonationDetail = 'receiverDonationDetail';
  static const receiverEnterCode = 'receiverEnterCode';
  static const receiverHandoverSuccess = 'receiverHandoverSuccess';
  static const receiverRequests = 'receiverRequests';
  static const receiverHistory = 'receiverHistory';
  static const receiverNotifications = 'receiverNotifications';
  static const receiverProfile = 'receiverProfile';
}

final routerProvider = Provider<GoRouter>((ref) {
  // Re-evaluate redirects whenever the session changes, so signing in from
  // the OTP screen immediately unlocks the role-guarded routes below.
  final sessionListenable = _SessionListenable(ref);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: sessionListenable,
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      final loggingIn =
          state.matchedLocation == '/' ||
          state.matchedLocation == '/login' ||
          state.matchedLocation.startsWith('/role') ||
          state.matchedLocation.startsWith('/auth');

      if (session == null) {
        return loggingIn ? null : '/';
      }
      // Role guard (ARCHITECTURE.md §2): a donor can never land on a
      // receiver route and vice versa, even via a deep link.
      if (session.role == UserRole.donor &&
          state.matchedLocation.startsWith('/receiver')) {
        return '/donor';
      }
      if (session.role == UserRole.receiver &&
          state.matchedLocation.startsWith('/donor')) {
        return '/receiver';
      }
      if (loggingIn) {
        return session.role == UserRole.donor ? '/donor' : '/receiver';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: AppRoute.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/role-select',
        name: AppRoute.roleSelect,
        builder: (context, state) => const RoleSelectScreen(),
      ),
      GoRoute(
        path: '/auth/phone',
        name: AppRoute.phone,
        builder: (context, state) =>
            PhoneScreen(role: state.extra! as UserRole),
      ),
      GoRoute(
        path: '/auth/otp',
        name: AppRoute.otp,
        builder: (context, state) {
          final args = state.extra! as OtpScreenArgs;
          return OtpScreen(args: args);
        },
      ),
       GoRoute(
  path: '/login',
  name: 'login',
  builder: (context, state) => const LoginScreen(),
),

      // Donor
      GoRoute(
        path: '/donor',
        name: AppRoute.donorDashboard,
        builder: (context, state) => const DonorDashboardScreen(),
        routes: [
          GoRoute(
            path: 'create',
            name: AppRoute.donorCreate,
            builder: (context, state) => const CreateDonationScreen(),
          ),
          GoRoute(
            path: 'donation/:id',
            name: AppRoute.donorDonationDetail,
            builder: (context, state) => DonorDonationDetailScreen(
              donationId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: 'recurring',
            name: AppRoute.donorRecurring,
            builder: (context, state) => const RecurringTemplatesScreen(),
          ),
          GoRoute(
            path: 'history',
            name: AppRoute.donorHistory,
            builder: (context, state) => const DonorHistoryScreen(),
          ),
          GoRoute(
            path: 'notifications',
            name: AppRoute.donorNotifications,
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: 'profile',
            name: AppRoute.donorProfile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Receiver
      GoRoute(
        path: '/receiver',
        name: AppRoute.receiverFeed,
        builder: (context, state) => const ReceiverFeedScreen(),
        routes: [
          GoRoute(
            path: 'donation/:id',
            name: AppRoute.receiverDonationDetail,
            builder: (context, state) =>
                DonationDetailScreen(donationId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'donation/:id/enter-code',
            name: AppRoute.receiverEnterCode,
            builder: (context, state) =>
                EnterPickupCodeScreen(donationId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'donation/:id/collected',
            name: AppRoute.receiverHandoverSuccess,
            builder: (context, state) =>
                HandoverSuccessScreen(donationId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'requests',
            name: AppRoute.receiverRequests,
            builder: (context, state) => const MyRequestsScreen(),
          ),
          GoRoute(
            path: 'history',
            name: AppRoute.receiverHistory,
            builder: (context, state) => const ReceiverHistoryScreen(),
          ),
          GoRoute(
            path: 'notifications',
            name: AppRoute.receiverNotifications,
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: 'profile',
            name: AppRoute.receiverProfile,
            builder: (context, state) => const ProfileScreen(),
          ),
         
        ],
      ),
    ],
  );
});

class _SessionListenable extends ChangeNotifier {
  _SessionListenable(this._ref) {
    _ref.listen(sessionProvider, (_, _) => notifyListeners());
  }

  final Ref _ref;
}
