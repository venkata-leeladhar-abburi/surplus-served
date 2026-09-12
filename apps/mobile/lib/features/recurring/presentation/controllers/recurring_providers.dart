import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers.dart';
import '../../domain/recurring_template.dart';

final recurringTemplatesProvider = StreamProvider<List<RecurringTemplate>>((
  ref,
) {
  final session = ref.watch(sessionProvider);
  if (session == null) return const Stream.empty();
  return ref.watch(recurringRepositoryProvider).watchTemplates(session.userId);
});
