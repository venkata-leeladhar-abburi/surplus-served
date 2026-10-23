import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/allocation/data/allocation_repository_fixture.dart';
import '../features/allocation/domain/allocation_repository.dart';
import '../features/auth/data/auth_repository_fixture.dart';
import '../features/auth/data/http_auth_repository.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/auth/domain/session.dart';
import '../features/discovery/data/discovery_repository_fixture.dart';
import '../features/discovery/domain/discovery_repository.dart';
import '../features/donation/data/http_donation_repository.dart'; // <-- Ensure this is imported
import '../features/donation/domain/donation_repository.dart';
import '../features/notifications/data/notification_repository_fixture.dart';
import '../features/notifications/domain/notification_repository.dart';
import '../features/recurring/data/recurring_repository_fixture.dart';
import '../features/recurring/domain/recurring_repository.dart';
import '../shared/fixtures/fixture_store.dart';

final fixtureStoreProvider = Provider<FixtureStore>(
  (ref) => FixtureStore.instance,
);

// Swapped fixture to HTTP Repository for live backend persistence
final donationRepositoryProvider = Provider<DonationRepository>(
  (ref) => HttpDonationRepository(),
);

final discoveryRepositoryProvider = Provider<DiscoveryRepository>(
  (ref) => DiscoveryRepositoryFixture(ref.watch(fixtureStoreProvider)),
);

final allocationRepositoryProvider = Provider<AllocationRepository>(
  (ref) => AllocationRepositoryFixture(ref.watch(fixtureStoreProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) {return HttpAuthRepository();}
);

final recurringRepositoryProvider = Provider<RecurringRepository>(
  (ref) => RecurringRepositoryFixture(ref.watch(donationRepositoryProvider)),
);

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepositoryFixture(),
);

class SessionNotifier extends Notifier<Session?> {
  @override
  Session? build() => null;

  void signIn(Session session) => state = session;

  void signOut() => state = null;
}

final sessionProvider = NotifierProvider<SessionNotifier, Session?>(
  SessionNotifier.new,
);
