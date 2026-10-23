import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers.dart';
import '../../domain/donation.dart';

/// The signed-in donor's own donations, newest first, fetched from the backend.
final donorDonationsProvider = StreamProvider<List<Donation>>((ref) {
  final session = ref.watch(sessionProvider);
  if (session == null) return const Stream.empty();
  return ref
      .watch(donationRepositoryProvider)
      .watchDonorDonations(session.userId);
});

/// A single donation tracked by its ID, fetched via the repository.
final donationByIdProvider = StreamProvider.family<Donation, String>((ref, id) async* {
  final repository = ref.watch(donationRepositoryProvider);
  yield await repository.getById(id);
});
