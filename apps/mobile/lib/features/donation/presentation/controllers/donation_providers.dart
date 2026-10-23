import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers.dart';
import '../../data/http_donation_repository.dart';
import '../../domain/donation.dart';
import '../../domain/donation_repository.dart';

/// Provides the HTTP-backed donation repository connected to your Render backend.
final donationRepositoryProvider = Provider<DonationRepository>((ref) {
  return HttpDonationRepository();
});

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
  // Yield the current fetch result for this specific donation ID
  yield await repository.getById(id);
});
