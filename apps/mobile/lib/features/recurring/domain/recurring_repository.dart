import 'recurring_template.dart';

abstract class RecurringRepository {
  Stream<List<RecurringTemplate>> watchTemplates(String donorId);

  Future<RecurringTemplate> createTemplate({
    required String donorId,
    required String donorName,
    required String title,
    required int portions,
    required int windowHours,
    required String locality,
  });

  /// Posts today's instance as a real donation (through
  /// `DonationRepository`) and marks the template confirmed for today.
  Future<void> confirmToday(String templateId);

  Future<void> skipToday(String templateId);

  Future<void> setActive(String templateId, bool active);
}
