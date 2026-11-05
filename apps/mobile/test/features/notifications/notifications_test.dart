import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ss_design_system/ss_design_system.dart';
import 'package:surplus_served_mobile/core/l10n/app_localizations.dart';
import 'package:surplus_served_mobile/core/providers.dart';
import 'package:surplus_served_mobile/features/auth/domain/session.dart';
import 'package:surplus_served_mobile/features/auth/domain/user_role.dart';
import 'package:surplus_served_mobile/features/notifications/data/http_notification_repository.dart';
import 'package:surplus_served_mobile/features/notifications/domain/app_notification.dart';
import 'package:surplus_served_mobile/features/notifications/domain/notification_repository.dart';
import 'package:surplus_served_mobile/features/notifications/presentation/controllers/notification_providers.dart';
import 'package:surplus_served_mobile/features/notifications/presentation/screens/notifications_screen.dart';

Map<String, dynamic> _json(String id, String type, {bool read = false}) => {
      '_id': id,
      'type': type,
      'title': 'Title $id',
      'body': 'Body $id',
      'donationId': 'd1',
      'read': read,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    };

class _FakeRepo implements NotificationRepository {
  _FakeRepo(this.items);

  List<AppNotification> items;
  final markedRead = <String>[];
  var markedAll = false;

  @override
  Future<NotificationFeed> fetch() async => NotificationFeed(
        items: items,
        unreadCount: items.where((n) => !n.read).length,
      );

  @override
  Future<void> markRead(String id) async {
    markedRead.add(id);
    items = [for (final n in items) n.id == id ? n.copyWith(read: true) : n];
  }

  @override
  Future<void> markAllRead() async {
    markedAll = true;
    items = [for (final n in items) n.copyWith(read: true)];
  }
}

class _SignedIn extends SessionNotifier {
  _SignedIn(this.role);
  final UserRole role;

  @override
  Session? build() =>
      Session(userId: 'u1', name: 'U', phone: '', role: role, token: 't');
}

Future<_FakeRepo> _pump(WidgetTester tester, List<AppNotification> items,
    {UserRole role = UserRole.ngo}) async {
  final repo = _FakeRepo(items);
  // Alerts open other tabs; give them simple stand-in pages.
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => const NotificationsScreen()),
      for (final name in ['receiverFeed', 'receiverRequests', 'receiverHistory'])
        GoRoute(
          path: '/$name',
          name: name,
          builder: (_, _) => Scaffold(body: Text('Page $name')),
        ),
      GoRoute(
        path: '/donation/:id',
        name: 'donorDonationDetail',
        builder: (_, state) =>
            Scaffold(body: Text('Donation ${state.pathParameters['id']}')),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sessionProvider.overrideWith(() => _SignedIn(role)),
        notificationRepositoryProvider.overrideWithValue(repo),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        theme: SsTheme.light(),
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

void main() {
  group('HttpNotificationRepository', () {
    test('parses alerts and unread count with the auth header', () async {
      late http.Request sent;
      final repo = HttpNotificationRepository(
        authToken: 'tok',
        client: MockClient((req) async {
          sent = req;
          return http.Response(
            jsonEncode({
              'unreadCount': 1,
              'notifications': [
                _json('n1', 'request_approved'),
                _json('n2', 'request_to_review', read: true),
              ],
            }),
            200,
          );
        }),
      );

      final feed = await repo.fetch();

      expect(sent.method, 'GET');
      expect(sent.url.path, '/api/notifications');
      expect(sent.headers['Authorization'], 'Bearer tok');
      expect(feed.unreadCount, 1);
      expect(feed.items.map((n) => n.id), ['n1', 'n2']);
      expect(feed.items.first.tone, NotificationTone.success);
      expect(feed.items.last.read, isTrue);
      expect(feed.items.first.donationId, 'd1');
    });

    test('mark read and read-all hit the right endpoints', () async {
      final calls = <String>[];
      final repo = HttpNotificationRepository(
        authToken: 'tok',
        client: MockClient((req) async {
          calls.add('${req.method} ${req.url.path}');
          return http.Response('{}', 200);
        }),
      );

      await repo.markRead('n1');
      await repo.markAllRead();

      expect(calls, [
        'PATCH /api/notifications/n1/read',
        'POST /api/notifications/read-all',
      ]);
    });

    test('server error message is shown', () async {
      final repo = HttpNotificationRepository(
        authToken: 'tok',
        client: MockClient(
          (_) async =>
              http.Response(jsonEncode({'message': 'Alert not found.'}), 404),
        ),
      );
      await expectLater(
        repo.markRead('x'),
        throwsA(predicate((e) => '$e'.contains('Alert not found.'))),
      );
    });

    test('needs a login', () {
      final repo = HttpNotificationRepository(authToken: null);
      expect(repo.fetch(), throwsA(isA<Exception>()));
    });
  });

  group('Alerts screen', () {
    testWidgets('lists alerts with an unread badge on the Alerts tab',
        (tester) async {
      await _pump(tester, [
        AppNotification.fromJson(_json('n1', 'request_approved')),
        AppNotification.fromJson(_json('n2', 'reduced_offer')),
        AppNotification.fromJson(_json('n3', 'ngo_verified', read: true)),
      ]);

      expect(find.text('Title n1'), findsOneWidget);
      expect(find.text('Body n2'), findsOneWidget);
      expect(find.text('Title n3'), findsOneWidget);
      // Two unread -> badge "2" on the bottom nav.
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Mark all read'), findsOneWidget);
    });

    testWidgets('mark all read clears the badge', (tester) async {
      final repo = await _pump(tester, [
        AppNotification.fromJson(_json('n1', 'request_approved')),
        AppNotification.fromJson(_json('n2', 'reduced_offer')),
      ]);

      await tester.tap(find.byKey(const Key('markAllReadButton')));
      await tester.pumpAndSettle();

      expect(repo.markedAll, isTrue);
      expect(find.text('2'), findsNothing);
      expect(find.text('Mark all read'), findsNothing);
    });

    testWidgets('tapping an unread alert marks it read', (tester) async {
      final repo = await _pump(tester, [
        AppNotification.fromJson(_json('n1', 'ngo_verified')),
      ]);

      await tester.tap(find.text('Title n1'));
      await tester.pumpAndSettle();

      expect(repo.markedRead, ['n1']);
    });

    testWidgets('empty state when there are no alerts', (tester) async {
      await _pump(tester, const [], role: UserRole.donor);
      expect(find.byType(SsEmptyState), findsOneWidget);
    });
  });

  test('badge count is 0 when alerts fail to load (no crash)', () async {
    final container = ProviderContainer(
      overrides: [
        notificationsProvider.overrideWith(
          (ref) async => throw Exception('offline'),
        ),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(notificationsProvider.future),
      throwsA(isA<Exception>()),
    );
    expect(container.read(unreadAlertsCountProvider), 0);
  });
}
