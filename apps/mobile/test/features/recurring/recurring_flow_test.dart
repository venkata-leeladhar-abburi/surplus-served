import 'package:flutter_test/flutter_test.dart';
import 'package:surplus_served_mobile/features/donation/data/donation_repository_fixture.dart';
import 'package:surplus_served_mobile/features/donation/domain/donation_repository.dart';
import 'package:surplus_served_mobile/features/recurring/data/recurring_repository_fixture.dart';
import 'package:surplus_served_mobile/shared/fixtures/fixture_store.dart';

void main() {
  test('confirming a template posts a real donation through DonationRepository', () async {
    final donationRepo = DonationRepositoryFixture(FixtureStore.instance);
    final recurringRepo = RecurringRepositoryFixture(donationRepo);

    final templates = await recurringRepo.watchTemplates('donor-demo').first;
    expect(templates, isNotEmpty);
    final template = templates.first;
    expect(template.needsTodayDecision, isTrue);

    final before = await donationRepo.watchDonorDonations('donor-demo').first;

    await recurringRepo.confirmToday(template.id);

    final after = await donationRepo.watchDonorDonations('donor-demo').first;
    expect(after.length, before.length + 1);

    final updated = await recurringRepo.watchTemplates('donor-demo').first;
    expect(updated.first.confirmedToday, isTrue);
    expect(updated.first.needsTodayDecision, isFalse);
  });

  test('skipping a template does not post a donation', () async {
    final DonationRepository donationRepo = DonationRepositoryFixture(FixtureStore.instance);
    final recurringRepo = RecurringRepositoryFixture(donationRepo);

    final template = (await recurringRepo.watchTemplates('donor-demo').first).first;
    final before = await donationRepo.watchDonorDonations('donor-demo').first;

    await recurringRepo.skipToday(template.id);

    final after = await donationRepo.watchDonorDonations('donor-demo').first;
    expect(after.length, before.length);

    final updated = (await recurringRepo.watchTemplates('donor-demo').first).first;
    expect(updated.skippedToday, isTrue);
  });
}
