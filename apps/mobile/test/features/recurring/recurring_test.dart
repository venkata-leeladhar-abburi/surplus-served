import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ss_design_system/ss_design_system.dart';
import 'package:surplus_served_mobile/core/l10n/app_localizations.dart';
import 'package:surplus_served_mobile/core/providers.dart';
import 'package:surplus_served_mobile/features/auth/domain/session.dart';
import 'package:surplus_served_mobile/features/auth/domain/user_role.dart';
import 'package:surplus_served_mobile/features/donation/domain/donation.dart';
import 'package:surplus_served_mobile/features/donation/presentation/controllers/donation_providers.dart';
import 'package:surplus_served_mobile/features/notifications/domain/app_notification.dart';
import 'package:surplus_served_mobile/features/notifications/presentation/controllers/notification_providers.dart';
import 'package:surplus_served_mobile/features/recurring/data/http_recurring_repository.dart';
import 'package:surplus_served_mobile/features/recurring/domain/recurring_repository.dart';
import 'package:surplus_served_mobile/features/recurring/domain/recurring_template.dart';
import 'package:surplus_served_mobile/features/recurring/presentation/screens/recurring_templates_screen.dart';

Map<String, dynamic> _json(String id, {bool active = true, bool confirmed = false}) => {
      '_id': id,
      'title': 'Meal $id',
      'portions': 25,
      'windowHours': 2,
      'safeHours': 4,
      'locality': 'Ameerpet',
      'foodCategory': 'cooked_meal',
      'dietType': 'veg',
      'active': active,
      'confirmedToday': confirmed,
      'skippedToday': false,
    };

class _FakeRepo implements RecurringRepository {
  _FakeRepo(this.templates);

  List<RecurringTemplate> templates;
  final confirmed = <String, int?>{};
  final skipped = <String>[];
  final created = <Map<String, Object?>>[];
  final activeChanges = <String, bool>{};

  @override
  Future<List<RecurringTemplate>> fetchTemplates() async => templates;

  @override
  Future<void> confirmToday(String templateId, {int? portions}) async {
    confirmed[templateId] = portions;
    templates = [
      for (final t in templates)
        t.id == templateId
            ? RecurringTemplate.fromJson({..._json(t.id), 'confirmedToday': true})
            : t,
    ];
  }

  @override
  Future<void> skipToday(String templateId) async => skipped.add(templateId);

  @override
  Future<void> setActive(String templateId, bool active) async =>
      activeChanges[templateId] = active;

  @override
  Future<void> deleteTemplate(String templateId) async {}

  @override
  Future<RecurringTemplate> createTemplate({
    required String title,
    required int portions,
    required int windowHours,
    required int safeHours,
    required String locality,
    required String foodCategory,
    String? dietType,
  }) async {
    created.add({
      'title': title,
      'portions': portions,
      'windowHours': windowHours,
      'safeHours': safeHours,
      'locality': locality,
      'foodCategory': foodCategory,
      'dietType': dietType,
    });
    final t = RecurringTemplate.fromJson({..._json('new'), 'title': title});
    templates = [...templates, t];
    return t;
  }
}

class _Donor extends SessionNotifier {
  @override
  Session? build() => const Session(
      userId: 'u1', name: 'Donor', phone: '', role: UserRole.donor, token: 't');
}

Future<_FakeRepo> _pump(WidgetTester tester, List<RecurringTemplate> items) async {
  final repo = _FakeRepo(items);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sessionProvider.overrideWith(_Donor.new),
        recurringRepositoryProvider.overrideWithValue(repo),
        donorDonationsProvider
            .overrideWith((ref) => const Stream<List<Donation>>.empty()),
        notificationsProvider
            .overrideWith((ref) async => NotificationFeed.empty),
      ],
      child: MaterialApp(
        theme: SsTheme.light(),
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const RecurringTemplatesScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

void main() {
  group('HttpRecurringRepository', () {
    test('create sends all template fields', () async {
      late http.Request sent;
      final repo = HttpRecurringRepository(
        authToken: 'tok',
        client: MockClient((req) async {
          sent = req;
          return http.Response(jsonEncode({'template': _json('t1')}), 201);
        }),
      );

      final t = await repo.createTemplate(
        title: 'Meal t1',
        portions: 25,
        windowHours: 2,
        safeHours: 4,
        locality: 'Ameerpet',
        foodCategory: 'cooked_meal',
        dietType: 'veg',
      );

      expect(sent.method, 'POST');
      expect(sent.url.path, '/api/recurring');
      expect(sent.headers['Authorization'], 'Bearer tok');
      expect(jsonDecode(sent.body), {
        'title': 'Meal t1',
        'portions': 25,
        'windowHours': 2,
        'safeHours': 4,
        'locality': 'Ameerpet',
        'foodCategory': 'cooked_meal',
        'dietType': 'veg',
      });
      expect(t.id, 't1');
      expect(t.needsTodayDecision, isTrue);
    });

    test('confirm, skip, pause and delete use the right endpoints', () async {
      final calls = <String>[];
      final repo = HttpRecurringRepository(
        authToken: 'tok',
        client: MockClient((req) async {
          calls.add('${req.method} ${req.url.path} ${req.body}');
          return http.Response('{}', 200);
        }),
      );

      await repo.confirmToday('t1', portions: 12);
      await repo.skipToday('t1');
      await repo.setActive('t1', false);
      await repo.deleteTemplate('t1');

      expect(calls, [
        'POST /api/recurring/t1/confirm {"portions":12}',
        'POST /api/recurring/t1/skip {}',
        'PATCH /api/recurring/t1 {"active":false}',
        'DELETE /api/recurring/t1 ',
      ]);
    });

    test('server error message is shown', () async {
      final repo = HttpRecurringRepository(
        authToken: 'tok',
        client: MockClient((_) async => http.Response(
              jsonEncode({
                'message': 'Today was already confirmed or skipped for this donation.',
              }),
              409,
            )),
      );
      await expectLater(
        repo.confirmToday('t1'),
        throwsA(predicate((e) => '$e'.contains('already confirmed'))),
      );
    });
  });

  group('Recurring screen', () {
    testWidgets('confirm asks for today\'s portions and posts', (tester) async {
      final repo = await _pump(tester, [RecurringTemplate.fromJson(_json('t1'))]);

      expect(find.text('Meal t1'), findsOneWidget);
      expect(find.textContaining('Cooked meal · Veg · Safe for 4 h'),
          findsOneWidget);

      await tester.tap(find.text('Confirm today'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).last, '12');
      await tester.tap(find.text('Post now'));
      await tester.pumpAndSettle();

      expect(repo.confirmed, {'t1': 12});
      expect(find.text('Posted today'), findsOneWidget);
      expect(find.text('Confirm today'), findsNothing);
    });

    testWidgets('skip calls the API', (tester) async {
      final repo = await _pump(tester, [RecurringTemplate.fromJson(_json('t1'))]);

      await tester.tap(find.text('Skip today'));
      await tester.pumpAndSettle();

      expect(repo.skipped, ['t1']);
    });

    testWidgets('paused template shows Paused and no daily actions',
        (tester) async {
      await _pump(tester, [RecurringTemplate.fromJson(_json('t1', active: false))]);

      expect(find.text('Paused'), findsOneWidget);
      expect(find.text('Confirm today'), findsNothing);
    });

    testWidgets('pause from the menu', (tester) async {
      final repo = await _pump(tester, [RecurringTemplate.fromJson(_json('t1'))]);

      await tester.tap(find.byKey(const Key('recurringMenu-t1')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pause'));
      await tester.pumpAndSettle();

      expect(repo.activeChanges, {'t1': false});
    });

    testWidgets('create sheet saves a new template', (tester) async {
      final repo = await _pump(tester, const []);

      await tester.tap(find.byKey(const Key('addRecurringButton')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('recurringTitleField')),
          matching: find.byType(TextField),
        ),
        'Hostel dinner',
      );
      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('recurringLocalityField')),
          matching: find.byType(TextField),
        ),
        'Ameerpet',
      );
      await tester.pumpAndSettle();
      final save = find.byKey(const Key('recurringSaveButton'));
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();

      expect(repo.created.single['title'], 'Hostel dinner');
      expect(repo.created.single['locality'], 'Ameerpet');
      expect(repo.created.single['foodCategory'], 'cooked_meal');
      expect(
        (repo.created.single['safeHours'] as int) >=
            (repo.created.single['windowHours'] as int),
        isTrue,
      );
      expect(find.text('Hostel dinner'), findsOneWidget);
    });
  });
}
