import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers.dart';
import '../../data/admin_repository.dart';
import '../../domain/admin_models.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final session = ref.watch(sessionProvider);
  return AdminRepository(authToken: session?.token);
});

/// NGOs by verification status: pending, verified or rejected.
final adminNgosProvider =
    FutureProvider.family<List<NgoApplication>, String>((ref, status) {
  return ref.watch(adminRepositoryProvider).getNgos(status);
});

final adminStatsProvider = FutureProvider<AdminStats>((ref) {
  return ref.watch(adminRepositoryProvider).getStats();
});

final adminActivityProvider = FutureProvider<List<AdminActivity>>((ref) {
  return ref.watch(adminRepositoryProvider).getActivity();
});

final adminDonationsProvider = FutureProvider<List<AdminDonation>>((ref) {
  return ref.watch(adminRepositoryProvider).getDonations();
});
