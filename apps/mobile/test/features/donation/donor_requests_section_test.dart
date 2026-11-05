import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ss_design_system/ss_design_system.dart';
import 'package:surplus_served_mobile/core/providers.dart';
import 'package:surplus_served_mobile/features/allocation/domain/allocation.dart';
import 'package:surplus_served_mobile/features/allocation/domain/allocation_repository.dart';
import 'package:surplus_served_mobile/features/donation/domain/donation.dart';
import 'package:surplus_served_mobile/features/donation/presentation/controllers/donation_providers.dart';
import 'package:surplus_served_mobile/features/donation/presentation/widgets/donor_requests_section.dart';
import 'package:surplus_served_mobile/features/donation/presentation/widgets/pickup_details_dialog.dart';

/// Records which allocation endpoints the widget calls.
class _RecordingAllocationRepository implements AllocationRepository {
  final approved = <String>[];
  final rejected = <String>[];
  String? lastAddress;
  String? lastPhone;
  String? lastContactName;
  double? lastLatitude;
  double? lastLongitude;

  @override
  Future<void> approveAllocation({
    required String allocationId,
    required String pickupAddress,
    required String contactPhone,
    String? contactName,
    double? pickupLatitude,
    double? pickupLongitude,
  }) async {
    approved.add(allocationId);
    lastAddress = pickupAddress;
    lastPhone = contactPhone;
    lastContactName = contactName;
    lastLatitude = pickupLatitude;
    lastLongitude = pickupLongitude;
  }

  @override
  Future<void> rejectAllocation({required String allocationId}) async =>
      rejected.add(allocationId);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Allocation _allocation(String id, String status) => Allocation(
      id: id,
      donationId: 'd1',
      status: status,
      createdAt: DateTime(2026, 1, 1),
      ngoName: 'NGO $id',
      requestedPortions: 5,
      offeredPortions: 5,
      allocatedPortions: status == 'approved' ? 5 : 0,
    );

Future<_RecordingAllocationRepository> _pump(
  WidgetTester tester,
  List<Allocation> allocations,
) async {
  final repo = _RecordingAllocationRepository();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        donorAllocationsProvider.overrideWith((ref) async => allocations),
        allocationRepositoryProvider.overrideWithValue(repo),
        // No real GPS in tests.
        pickupLocationFetcherProvider.overrideWithValue(
          () async => (latitude: 17.4375, longitude: 78.4482),
        ),
        // Refresh after a decision re-reads these; keep them offline.
        donationByIdProvider.overrideWith(
          (ref, id) => const Stream<Donation>.empty(),
        ),
        donorDonationsProvider.overrideWith(
          (ref) => const Stream<List<Donation>>.empty(),
        ),
      ],
      child: MaterialApp(
        theme: SsTheme.light(),
        home: const Scaffold(
          body: SingleChildScrollView(
            child: DonorRequestsSection(donationId: 'd1'),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

void main() {
  testWidgets('shows Approve/Reject for pending_donor and Verify for approved',
      (tester) async {
    await _pump(tester, [
      _allocation('a1', 'pending_donor'),
      _allocation('a2', 'approved'),
      _allocation('a3', 'queued'),
    ]);

    expect(find.text('Approve'), findsOneWidget);
    expect(find.text('Reject'), findsOneWidget);
    expect(find.text('Verify pickup'), findsOneWidget);
    expect(find.textContaining('In queue'), findsOneWidget);
  });

  testWidgets('approving sends the pickup address and phone',
      (tester) async {
    final repo = await _pump(tester, [_allocation('a1', 'pending_donor')]);

    await tester.tap(find.text('Approve'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('pickupAddressField')),
      'Flat 4, Green Towers, Ameerpet, Hyderabad',
    );
    await tester.enterText(
      find.byKey(const Key('contactPhoneField')),
      '98765 43210',
    );
    await tester.tap(find.byKey(const Key('confirmApproveButton')));
    await tester.pumpAndSettle();

    expect(repo.approved, ['a1']);
    expect(repo.lastAddress, 'Flat 4, Green Towers, Ameerpet, Hyderabad');
    expect(repo.lastPhone, '9876543210');
    expect(repo.lastContactName, isNull);
    expect(repo.lastLatitude, isNull); // location is optional
    expect(repo.lastLongitude, isNull);
    expect(repo.rejected, isEmpty);
  });

  testWidgets('donor can pin the exact pickup location', (tester) async {
    final repo = await _pump(tester, [_allocation('a1', 'pending_donor')]);

    await tester.tap(find.text('Approve'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('pickupAddressField')),
      'Flat 4, Green Towers, Ameerpet, Hyderabad',
    );
    await tester.enterText(
      find.byKey(const Key('contactPhoneField')),
      '9876543210',
    );
    await tester.ensureVisible(find.byKey(const Key('useLocationButton')));
    await tester.tap(find.byKey(const Key('useLocationButton')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Exact location pinned'), findsOneWidget);

    await tester.tap(find.byKey(const Key('confirmApproveButton')));
    await tester.pumpAndSettle();

    expect(repo.approved, ['a1']);
    expect(repo.lastLatitude, 17.4375);
    expect(repo.lastLongitude, 78.4482);
  });

  testWidgets('approval is blocked until address and phone are valid',
      (tester) async {
    final repo = await _pump(tester, [_allocation('a1', 'pending_donor')]);

    await tester.tap(find.text('Approve'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('confirmApproveButton')));
    await tester.pumpAndSettle();
    expect(
      find.text('Enter the complete address (house, street, area).'),
      findsOneWidget,
    );
    expect(find.text('Enter a valid phone number (10-13 digits).'),
        findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('pickupAddressField')),
      'Flat 4, Green Towers, Ameerpet',
    );
    await tester.enterText(find.byKey(const Key('contactPhoneField')), '12345');
    await tester.tap(find.byKey(const Key('confirmApproveButton')));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid phone number (10-13 digits).'),
        findsOneWidget);
    expect(repo.approved, isEmpty);
  });

  testWidgets('rejecting calls the reject endpoint after confirmation',
      (tester) async {
    final repo = await _pump(tester, [_allocation('a1', 'pending_donor')]);

    await tester.tap(find.text('Reject'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reject').last);
    await tester.pumpAndSettle();

    expect(repo.rejected, ['a1']);
    expect(repo.approved, isEmpty);
  });

  testWidgets('ignores requests for other donations', (tester) async {
    await _pump(tester, [
      Allocation(
        id: 'x',
        donationId: 'other',
        status: 'pending_donor',
        createdAt: DateTime(2026, 1, 1),
      ),
    ]);

    expect(find.text('Approve'), findsNothing);
    expect(find.text('No NGO has requested this donation yet.'), findsOneWidget);
  });
}
