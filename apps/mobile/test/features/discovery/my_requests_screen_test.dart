import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ss_design_system/ss_design_system.dart';
import 'package:surplus_served_mobile/core/l10n/app_localizations.dart';
import 'package:surplus_served_mobile/core/providers.dart';
import 'package:surplus_served_mobile/features/allocation/domain/allocation.dart';
import 'package:surplus_served_mobile/features/allocation/domain/allocation_repository.dart';
import 'package:surplus_served_mobile/features/discovery/presentation/controllers/receiver_donations_providers.dart';
import 'package:surplus_served_mobile/features/discovery/presentation/screens/my_requests_screen.dart';
import 'package:surplus_served_mobile/features/donation/domain/donation.dart';
import 'package:surplus_served_mobile/features/donation/domain/donation_status.dart';
import 'package:surplus_served_mobile/shared/utils/allocation_status_mapper.dart';
import 'package:surplus_served_mobile/shared/utils/directions.dart';

class _RecordingAllocationRepository implements AllocationRepository {
  final offers = <(String, bool)>[];

  @override
  Future<void> confirmOffer({
    required String allocationId,
    required bool accept,
  }) async =>
      offers.add((allocationId, accept));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ReceiverAllocation _item(
  String id,
  String status, {
  String? pickupCode,
  int requested = 10,
  int? offered,
  String? pickupAddress,
  String? contactPhone,
  String? contactName,
  double? latitude,
  double? longitude,
}) =>
    ReceiverAllocation(
      allocation: Allocation(
        id: id,
        donationId: 'd$id',
        status: status,
        createdAt: DateTime(2026, 1, 1),
        requestedPortions: requested,
        offeredPortions: offered,
        pickupCode: pickupCode,
        pickupAddress: pickupAddress,
        contactPhone: contactPhone,
        contactName: contactName,
        pickupLatitude: latitude,
        pickupLongitude: longitude,
      ),
      donation: Donation(
        id: 'd$id',
        donorId: 'donor',
        donorName: 'Kitchen $id',
        title: 'Meal $id',
        portions: requested,
        status: DonationStatus.live,
        pickupWindowStart: DateTime(2026, 1, 1),
        pickupWindowEnd: DateTime(2026, 1, 1, 2),
        address: const PickupAddress(locality: 'Area'),
        createdAt: DateTime(2026, 1, 1),
      ),
    );

Future<_RecordingAllocationRepository> _pump(
  WidgetTester tester,
  List<ReceiverAllocation> items,
) async {
  final repo = _RecordingAllocationRepository();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        receiverAllocationsProvider.overrideWith((ref) async => items),
        allocationRepositoryProvider.overrideWithValue(repo),
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
        home: const MyRequestsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

void main() {
  test('active vs finished allocation statuses', () {
    for (final s in [
      'queued',
      'awaiting_ngo_confirmation',
      'pending_donor',
      'approved',
    ]) {
      expect(AllocationStatusView.isActive(s), isTrue, reason: s);
    }
    for (final s in ['collected', 'rejected', 'declined', 'expired', 'cancelled']) {
      expect(AllocationStatusView.isActive(s), isFalse, reason: s);
    }
  });

  testWidgets('shows active requests only, with pickup code when approved',
      (tester) async {
    await _pump(tester, [
      _item('1', 'approved', pickupCode: '123456'),
      _item('2', 'pending_donor'),
      _item('3', 'collected'),
    ]);

    expect(find.text('Meal 1'), findsOneWidget);
    expect(find.text('123456'), findsOneWidget);
    expect(find.text('Meal 2'), findsOneWidget);
    expect(find.text('Awaiting donor'), findsOneWidget);
    expect(find.text('Meal 3'), findsNothing); // finished -> History tab
  });

  testWidgets('approved request shows the donor address and phone',
      (tester) async {
    await _pump(tester, [
      _item(
        '1',
        'approved',
        pickupCode: '123456',
        pickupAddress: 'Flat 4, Green Towers, Ameerpet, Hyderabad',
        contactPhone: '9876543210',
        contactName: 'Ravi',
      ),
    ]);

    expect(find.text('Pickup address'), findsOneWidget);
    expect(
      find.text('Flat 4, Green Towers, Ameerpet, Hyderabad'),
      findsOneWidget,
    );
    expect(find.text('Ravi · 9876543210'), findsOneWidget);
    expect(find.text('Call'), findsOneWidget);
    expect(find.text('Directions'), findsOneWidget);
  });

  testWidgets('pinned location shows exact-pin directions', (tester) async {
    await _pump(tester, [
      _item(
        '1',
        'approved',
        pickupCode: '123456',
        pickupAddress: 'Flat 4, Green Towers, Ameerpet, Hyderabad',
        contactPhone: '9876543210',
        latitude: 17.4375,
        longitude: 78.4482,
      ),
    ]);

    expect(find.text('Directions (exact pin)'), findsOneWidget);
  });

  test('directions link uses the pin when there is one, else the address',
      () {
    final pinned = pickupDirectionsUri(
      address: 'Ameerpet',
      latitude: 17.4375,
      longitude: 78.4482,
    );
    expect(pinned.host, 'www.google.com');
    expect(pinned.queryParameters['destination'], '17.4375,78.4482');

    final byAddress = pickupDirectionsUri(address: 'Flat 4, Ameerpet');
    expect(byAddress.queryParameters['destination'], 'Flat 4, Ameerpet');
    expect(byAddress.queryParameters['api'], '1');
  });

  testWidgets('NGO can accept a reduced-quantity offer', (tester) async {
    final repo = await _pump(tester, [
      _item('1', 'awaiting_ngo_confirmation', requested: 10, offered: 4),
    ]);

    expect(find.textContaining('Only 4 of the 10'), findsOneWidget);

    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Accept').last);
    await tester.pumpAndSettle();

    expect(repo.offers, [('1', true)]);
  });

  testWidgets('NGO can decline a reduced-quantity offer', (tester) async {
    final repo = await _pump(tester, [
      _item('1', 'awaiting_ngo_confirmation', requested: 10, offered: 4),
    ]);

    await tester.tap(find.text('Decline'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Decline').last);
    await tester.pumpAndSettle();

    expect(repo.offers, [('1', false)]);
  });
}
