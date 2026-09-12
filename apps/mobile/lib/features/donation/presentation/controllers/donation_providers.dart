import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers.dart';
import '../../domain/donation.dart';

/// The signed-in donor's own donations, newest first, live-updating as the
/// fixture store (or eventually the socket) pushes state changes.
final donorDonationsProvider = StreamProvider<List<Donation>>((ref) {
  final session = ref.watch(sessionProvider);
  if (session == null) return const Stream.empty();
  return ref.watch(donationRepositoryProvider).watchDonorDonations(session.userId);
});

/// A single donation, tracked live — used by both the donor's own detail
/// screen and the receiver's, so everyone watching a donation sees the same
/// `live → allocated → collected` transition as it happens.
final donationByIdProvider = StreamProvider.family<Donation, String>((ref, id) {
  final store = ref.watch(fixtureStoreProvider);
  return store.watchAll().map((all) => all.firstWhere((d) => d.id == id));
});
