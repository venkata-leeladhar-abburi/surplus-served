/// A standing "I donate this every day" pattern — scope's recurring
/// donations feature. Each day the donor either confirms (which posts a
/// real `Donation` through the normal flow) or skips.
class RecurringTemplate {
  const RecurringTemplate({
    required this.id,
    required this.donorId,
    required this.donorName,
    required this.title,
    required this.portions,
    required this.windowHours,
    required this.locality,
    required this.active,
    this.confirmedToday = false,
    this.skippedToday = false,
  });

  final String id;
  final String donorId;
  final String donorName;
  final String title;
  final int portions;
  final int windowHours;
  final String locality;
  final bool active;

  /// Whether today's instance has already been posted or skipped — once
  /// either is true the "Confirm today" / "Skip today" actions retire for
  /// the day, same as the real daily job would enforce server-side.
  final bool confirmedToday;
  final bool skippedToday;

  bool get needsTodayDecision => active && !confirmedToday && !skippedToday;

  RecurringTemplate copyWith({
    bool? active,
    bool? confirmedToday,
    bool? skippedToday,
  }) {
    return RecurringTemplate(
      id: id,
      donorId: donorId,
      donorName: donorName,
      title: title,
      portions: portions,
      windowHours: windowHours,
      locality: locality,
      active: active ?? this.active,
      confirmedToday: confirmedToday ?? this.confirmedToday,
      skippedToday: skippedToday ?? this.skippedToday,
    );
  }
}
