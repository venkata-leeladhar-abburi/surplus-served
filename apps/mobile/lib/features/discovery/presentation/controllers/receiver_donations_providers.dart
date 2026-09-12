import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers.dart';
import '../../../donation/domain/donation.dart';

/// Every donation this NGO holds or has held an allocation for — the
/// receiver-side mirror of `donorDonationsProvider`, filtered by
/// `allocatedToNgoId` instead of `donorId` since a receiver never "owns" a
/// donation the way a donor does.
final receiverDonationsProvider = StreamProvider<List<Donation>>((ref) {
  final session = ref.watch(sessionProvider);
  if (session == null) return const Stream.empty();
  final store = ref.watch(fixtureStoreProvider);
  return store.watchAll().map(
        (all) => all.where((d) => d.allocatedToNgoId == session.userId).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
      );
});
