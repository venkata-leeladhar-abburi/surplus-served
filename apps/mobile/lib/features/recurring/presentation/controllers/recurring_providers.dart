import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers.dart';
import '../../domain/recurring_template.dart';

final recurringTemplatesProvider =
    FutureProvider<List<RecurringTemplate>>((ref) async {
  final session = ref.watch(sessionProvider);
  if (session == null) return const [];
  return ref.watch(recurringRepositoryProvider).fetchTemplates();
});
