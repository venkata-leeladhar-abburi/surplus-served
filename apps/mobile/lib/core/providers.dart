import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/allocation/data/allocation_repository_fixture.dart';
import '../features/allocation/domain/allocation_repository.dart';
import '../features/auth/data/auth_repository_fixture.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/auth/domain/session.dart';
import '../features/discovery/data/discovery_repository_fixture.dart';
import '../features/discovery/domain/discovery_repository.dart';
import '../features/donation/data/donation_repository_fixture.dart';
import '../features/donation/domain/donation_repository.dart';
import '../shared/fixtures/fixture_store.dart';

/// The one place a concrete repository is chosen. A real build swaps the
/// fixture for a Dio/Drift-backed implementation here and nowhere else.
final fixtureStoreProvider = Provider<FixtureStore>((ref) => FixtureStore.instance);

final donationRepositoryProvider = Provider<DonationRepository>(
  (ref) => DonationRepositoryFixture(ref.watch(fixtureStoreProvider)),
);

final discoveryRepositoryProvider = Provider<DiscoveryRepository>(
  (ref) => DiscoveryRepositoryFixture(ref.watch(fixtureStoreProvider)),
);

final allocationRepositoryProvider = Provider<AllocationRepository>(
  (ref) => AllocationRepositoryFixture(ref.watch(fixtureStoreProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepositoryFixture());

/// The signed-in session, or null when signed out. Set by the auth
/// controller after OTP verification; read by the router's redirect guard.
class SessionNotifier extends Notifier<Session?> {
  @override
  Session? build() => null;

  void signIn(Session session) => state = session;

  void signOut() => state = null;
}

final sessionProvider = NotifierProvider<SessionNotifier, Session?>(SessionNotifier.new);
