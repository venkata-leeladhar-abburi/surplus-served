import 'dart:async';
import 'dart:math';

import '../../features/donation/domain/donation.dart';
import '../../features/donation/domain/donation_status.dart';

/// The one place all three fixture repositories read and write.
///
/// This stands in for `apps/api` today: a single source of truth that
/// broadcasts changes, so donor, discovery and allocation screens see the
/// same donation move through `draft → pendingCheck → live → allocated →
/// collected` in real time — the thing a vertical slice is meant to prove.
///
/// Swapping this for Dio + Socket.IO later touches only the three
/// `*RepositoryFixture` classes, never a screen or controller.
class FixtureStore {
  FixtureStore._() {
    _seed();
  }

  static final FixtureStore instance = FixtureStore._();

  final _donations = <String, Donation>{};
  final _controller = StreamController<List<Donation>>.broadcast();
  final _random = Random();

  void _seed() {
    final now = DateTime.now();
    _put(
      Donation(
        id: 'seed-1',
        donorId: 'donor-demo',
        donorName: 'Green Leaf Caterers',
        title: 'Vegetable biryani, 2 hours old',
        description: 'Cooked for a wedding, untouched trays.',
        portions: 40,
        status: DonationStatus.live,
        pickupWindowStart: now.subtract(const Duration(minutes: 10)),
        pickupWindowEnd: now.add(const Duration(hours: 2)),
        address: const PickupAddress(locality: 'Jubilee Hills, Hyderabad'),
        createdAt: now.subtract(const Duration(minutes: 20)),
      ),
    );
    _put(
      Donation(
        id: 'seed-2',
        donorId: 'donor-demo-2',
        donorName: 'Café Aroma',
        title: 'Sandwiches and salads',
        portions: 15,
        status: DonationStatus.live,
        pickupWindowStart: now,
        pickupWindowEnd: now.add(const Duration(minutes: 45)),
        address: const PickupAddress(locality: 'Banjara Hills, Hyderabad'),
        createdAt: now.subtract(const Duration(minutes: 5)),
      ),
    );
  }

  void _put(Donation d) {
    _donations[d.id] = d;
    _emit();
  }

  void _emit() => _controller.add(_donations.values.toList(growable: false));

  Stream<List<Donation>> watchAll() async* {
    yield _donations.values.toList(growable: false);
    yield* _controller.stream;
  }

  Donation getById(String id) {
    final d = _donations[id];
    if (d == null) throw StateError('No donation with id $id');
    return d;
  }

  Donation create({
    required String donorId,
    required String donorName,
    required String title,
    String? description,
    required int portions,
    required DateTime pickupWindowStart,
    required DateTime pickupWindowEnd,
    required PickupAddress address,
  }) {
    final id = 'd-${_donations.length + 1}-${_random.nextInt(9999)}';
    // pendingCheck → live is instant in the fixture; the real API runs an
    // automated safety check (scope §9) before flipping this.
    final donation = Donation(
      id: id,
      donorId: donorId,
      donorName: donorName,
      title: title,
      description: description,
      portions: portions,
      status: DonationStatus.live,
      pickupWindowStart: pickupWindowStart,
      pickupWindowEnd: pickupWindowEnd,
      address: address,
      createdAt: DateTime.now(),
    );
    _put(donation);
    return donation;
  }

  Donation cancel(String id) {
    final current = getById(id);
    if (!current.status.canTransitionTo(DonationStatus.cancelled)) {
      throw StateError('Cannot cancel a donation in ${current.status}');
    }
    final updated = current.copyWith(status: DonationStatus.cancelled);
    _put(updated);
    return updated;
  }

  /// Single-candidate allocation stand-in for `ranking.ts` — real weights
  /// are proximity/capacity/order/fairness (ARCHITECTURE.md §3); the
  /// fixture always allocates to whoever asked, since there is one NGO.
  Donation allocate({
    required String donationId,
    required String ngoId,
    required String ngoName,
  }) {
    final current = getById(donationId);
    if (!current.status.canTransitionTo(DonationStatus.allocated)) {
      throw StateError('Cannot allocate a donation in ${current.status}');
    }
    final code = (1000 + _random.nextInt(9000)).toString();
    final updated = current.copyWith(
      status: DonationStatus.allocated,
      allocatedToNgoId: ngoId,
      allocatedToNgoName: ngoName,
      pickupCode: code,
      // §11: exact address is added to the payload only once allocated.
      address: PickupAddress(
        locality: current.address.locality,
        exactLine: '14-2-118, Road No. 3, ${current.address.locality}',
        contactName: current.donorName,
        contactPhone: '+91 98765 43210',
        latitude: current.address.latitude,
        longitude: current.address.longitude,
      ),
    );
    _put(updated);
    return updated;
  }

  ({Donation donation, bool matched}) enterPickupCode({
    required String donationId,
    required String code,
  }) {
    final current = getById(donationId);
    if (current.pickupCode == null) {
      throw StateError('Donation $donationId has no pickup code to check');
    }
    if (current.pickupCode != code) {
      return (donation: current, matched: false);
    }
    final updated = current.copyWith(status: DonationStatus.collected);
    _put(updated);
    return (donation: updated, matched: true);
  }
}
