import 'recurring_template.dart';

/// Donor-only recurring donations (/api/recurring).
abstract class RecurringRepository {
  Future<List<RecurringTemplate>> fetchTemplates();

  Future<RecurringTemplate> createTemplate({
    required String title,
    required int portions,
    required int windowHours,
    required int safeHours,
    required String locality,
    required String foodCategory,
    String? dietType,
  });

  /// Posts today's donation from the template. [portions] overrides the
  /// usual quantity for today only.
  Future<void> confirmToday(String templateId, {int? portions});

  Future<void> skipToday(String templateId);

  Future<void> setActive(String templateId, bool active);

  Future<void> deleteTemplate(String templateId);
}
