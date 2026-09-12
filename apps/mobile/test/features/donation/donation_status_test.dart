import 'package:flutter_test/flutter_test.dart';
import 'package:surplus_served_mobile/features/donation/domain/donation_status.dart';

void main() {
  group('DonationStatus transitions', () {
    test('the happy path is legal end to end', () {
      expect(DonationStatus.draft.canTransitionTo(DonationStatus.pendingCheck), isTrue);
      expect(DonationStatus.pendingCheck.canTransitionTo(DonationStatus.live), isTrue);
      expect(DonationStatus.live.canTransitionTo(DonationStatus.allocated), isTrue);
      expect(DonationStatus.allocated.canTransitionTo(DonationStatus.collected), isTrue);
    });

    test('there is no in-transit state (scope §16 excludes delivery)', () {
      expect(DonationStatus.values.map((s) => s.name), isNot(contains('inTransit')));
    });

    test('terminal states have no legal next state', () {
      for (final terminal in [
        DonationStatus.collected,
        DonationStatus.unfulfilled,
        DonationStatus.cancelled,
        DonationStatus.rejected,
      ]) {
        expect(terminal.nextStates, isEmpty);
      }
    });

    test('live can be cancelled, allocated cannot', () {
      expect(DonationStatus.live.canTransitionTo(DonationStatus.cancelled), isTrue);
      expect(DonationStatus.allocated.canTransitionTo(DonationStatus.cancelled), isFalse);
    });

    test('isActive matches the lifecycle stages still in play', () {
      expect(DonationStatus.live.isActive, isTrue);
      expect(DonationStatus.allocated.isActive, isTrue);
      expect(DonationStatus.collected.isActive, isFalse);
      expect(DonationStatus.cancelled.isActive, isFalse);
    });
  });
}
