
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers.dart';
import '../../../allocation/data/http_allocation_repository.dart';
import '../../../allocation/domain/allocation.dart';
import '../../domain/donation.dart';

/// The signed-in donor's own donations, newest first.
final donorDonationsProvider = StreamProvider<List<Donation>>((ref) {
  final session = ref.watch(sessionProvider);

  if (session == null) return const Stream.empty();

  return ref
      .watch(donationRepositoryProvider)
      .watchDonorDonations(
        session.userId,
        authToken: session.token,
      );
});

/// A single donation tracked by its ID.
final donationByIdProvider =
    StreamProvider.family<Donation, String>((ref, id) async* {
  final session = ref.watch(sessionProvider);
  final repository = ref.watch(donationRepositoryProvider);

  yield await repository.getById(
    id,
    authToken: session?.token,
  );
});

/// Allocations belonging to the currently signed-in donor.
///
/// The donor response intentionally does not contain pickupCode.
/// The donor uses the allocation ID to submit the code entered at handover.
final donorAllocationsProvider = FutureProvider<List<Allocation>>((ref) async {
  final session = ref.watch(sessionProvider);

  if (session == null || session.token == null || session.token!.isEmpty) {
    throw Exception('Please log in to view your allocations.');
  }

  final repository = HttpAllocationRepository(
    authToken: session.token,
  );

  final response = await repository.getMyDonorAllocations();

  final allocations = response
      .map(Allocation.fromJson)
      .where((allocation) => allocation.id.isNotEmpty)
      .toList();

  allocations.sort(
    (a, b) => b.createdAt.compareTo(a.createdAt),
  );

  return allocations;
});
