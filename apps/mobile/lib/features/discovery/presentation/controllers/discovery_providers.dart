import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers.dart';
import '../../../donation/domain/donation.dart';

/// Live donations near the signed-in NGO, excluding the NGO's own posts —
/// harmless in the fixture (a single account is never both roles) but keeps
/// the query shape identical to the real PostGIS-backed one.
final receiverFeedProvider = StreamProvider<List<Donation>>((ref) {
  final session = ref.watch(sessionProvider);
  return ref.watch(discoveryRepositoryProvider).watchLiveFeed(excludeDonorId: session?.userId);
});
