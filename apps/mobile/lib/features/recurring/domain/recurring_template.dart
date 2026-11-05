/// A donor's standing "I have this surplus regularly" pattern, stored by
/// the backend (/api/recurring). Each day the donor either confirms (which
/// posts a real donation) or skips.
class RecurringTemplate {
  const RecurringTemplate({
    required this.id,
    required this.title,
    required this.portions,
    required this.windowHours,
    required this.safeHours,
    required this.locality,
    required this.active,
    this.foodCategory = 'other',
    this.dietType,
    this.confirmedToday = false,
    this.skippedToday = false,
  });

  final String id;
  final String title;
  final int portions;

  /// Pickup window length, starting when the donor confirms.
  final int windowHours;

  /// How long the food stays safe after confirming.
  final int safeHours;
  final String locality;
  final String foodCategory;
  final String? dietType;
  final bool active;

  /// Once either is true the day's Confirm / Skip actions retire; the
  /// server enforces this too.
  final bool confirmedToday;
  final bool skippedToday;

  bool get needsTodayDecision => active && !confirmedToday && !skippedToday;

  factory RecurringTemplate.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v, int fallback) =>
        v is num ? v.toInt() : int.tryParse('$v') ?? fallback;

    return RecurringTemplate(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      portions: toInt(json['portions'], 1),
      windowHours: toInt(json['windowHours'], 1),
      safeHours: toInt(json['safeHours'], 1),
      locality: json['locality']?.toString() ?? '',
      foodCategory: json['foodCategory']?.toString() ?? 'other',
      dietType: json['dietType']?.toString(),
      active: json['active'] != false,
      confirmedToday: json['confirmedToday'] == true,
      skippedToday: json['skippedToday'] == true,
    );
  }
}
