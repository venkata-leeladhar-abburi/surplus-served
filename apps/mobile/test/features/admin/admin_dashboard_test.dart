import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ss_design_system/ss_design_system.dart';
import 'package:surplus_served_mobile/core/l10n/app_localizations.dart';
import 'package:surplus_served_mobile/core/providers.dart';
import 'package:surplus_served_mobile/core/router/app_router.dart';
import 'package:surplus_served_mobile/features/admin/data/admin_repository.dart';
import 'package:surplus_served_mobile/features/admin/domain/admin_models.dart';
import 'package:surplus_served_mobile/features/admin/presentation/controllers/admin_providers.dart';
import 'package:surplus_served_mobile/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:surplus_served_mobile/features/auth/domain/session.dart';
import 'package:surplus_served_mobile/features/auth/domain/user_role.dart';

/// Keeps NGO state in memory so the screen can be exercised offline.
class _FakeAdminRepository extends AdminRepository {
  _FakeAdminRepository() : super(authToken: 'test');

  final approved = <String>[];
  final rejected = <String, String>{};

  @override
  Future<List<NgoApplication>> getNgos(String status) async {
    if (status != 'pending') return [];
    return [
      const NgoApplication(
        id: 'n1',
        contactName: 'Asha',
        email: 'asha@ngo.org',
        organizationName: 'Helping Hands',
        registrationNumber: 'REG-1',
        verificationStatus: 'pending',
        documentUrl: 'https://example.test/cert.png',
      ),
    ].where((n) => !approved.contains(n.id) && !rejected.containsKey(n.id)).toList();
  }

  @override
  Future<void> approveNgo(String ngoId) async => approved.add(ngoId);

  @override
  Future<void> rejectNgo(String ngoId, String reason) async =>
      rejected[ngoId] = reason;

  @override
  Future<AdminStats> getStats() async => AdminStats.fromJson(const {
        'users': {'donors': 3, 'ngosPending': 1, 'ngosVerified': 2, 'ngosRejected': 0},
        'donations': {'total': 5, 'available': 2, 'claimed': 1, 'collected': 2, 'cancelled': 0},
        'requests': {'active': 1, 'collected': 2},
        'portionsServed': 40,
      });

  @override
  Future<List<AdminActivity>> getActivity() async => [];

  @override
  Future<List<AdminDonation>> getDonations() async => [];
}

const _delegates = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

Future<_FakeAdminRepository> _pump(WidgetTester tester) async {
  final repo = _FakeAdminRepository();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [adminRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(
        theme: SsTheme.light(),
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: _delegates,
        home: const AdminDashboardScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

void main() {
  testWidgets('lists pending NGO with certificate and actions', (tester) async {
    await _pump(tester);

    expect(find.text('Helping Hands'), findsOneWidget);
    expect(find.text('View certificate'), findsOneWidget);
    expect(find.text('Approve'), findsOneWidget);
    expect(find.text('Reject'), findsOneWidget);
  });

  testWidgets('approve calls the API and removes the NGO from pending',
      (tester) async {
    final repo = await _pump(tester);

    await tester.tap(find.text('Approve'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Approve').last);
    await tester.pumpAndSettle();

    expect(repo.approved, ['n1']);
    expect(find.text('No pending applications'), findsOneWidget);
  });

  testWidgets('reject requires a reason', (tester) async {
    final repo = await _pump(tester);

    await tester.tap(find.text('Reject'));
    await tester.pumpAndSettle();

    // Empty reason is refused.
    await tester.tap(find.widgetWithText(FilledButton, 'Reject'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter a reason.'), findsOneWidget);
    expect(repo.rejected, isEmpty);

    await tester.enterText(find.byType(TextField), 'Certificate unreadable');
    await tester.tap(find.widgetWithText(FilledButton, 'Reject'));
    await tester.pumpAndSettle();

    expect(repo.rejected, {'n1': 'Certificate unreadable'});
  });

  testWidgets('overview tab shows platform stats', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('Overview'));
    await tester.pumpAndSettle();

    expect(find.text('Portions served'), findsOneWidget);
    expect(find.text('40'), findsOneWidget);
  });

  testWidgets('router keeps each role in its own area', (tester) async {
    final container = ProviderContainer(
      overrides: [
        adminRepositoryProvider.overrideWithValue(_FakeAdminRepository()),
      ],
    );
    addTearDown(container.dispose);
    final router = container.read(routerProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: SsTheme.light(),
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: _delegates,
          routerConfig: router,
        ),
      ),
    );

    Future<String> go(UserRole role, String path) async {
      container.read(sessionProvider.notifier).signIn(
            Session(userId: 'u', name: 'U', phone: '', role: role, token: 't'),
          );
      router.go(path);
      // Screens below try to load data; only the location matters here.
      await tester.pump();
      await tester.pump();
      return router.routerDelegate.currentConfiguration.uri.path;
    }

    expect(await go(UserRole.admin, '/login'), '/admin');
    expect(await go(UserRole.admin, '/donor'), '/admin');
    expect(await go(UserRole.admin, '/receiver'), '/admin');
    expect(await go(UserRole.donor, '/admin'), '/donor');
    expect(await go(UserRole.ngo, '/admin'), '/receiver');
    expect(await go(UserRole.ngo, '/donor'), '/receiver');

    // Leave the tree before the container is disposed, and let the
    // splash screen's delayed redirect timer finish.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  });
}
