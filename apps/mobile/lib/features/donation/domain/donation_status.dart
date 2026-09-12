/// The donation lifecycle, as scope §16 defines it.
///
/// Pure Dart — no Flutter, no presentation concerns. `SsStatus` in the design
/// system carries the colour/icon/label for a status; this is the source of
/// truth for what states exist and which transitions are legal.
///
/// Deliberately has no `inTransit` member: scope §3/§17 rule out delivery —
/// v1 is self-collect only. See `docs/DESIGN_SYSTEM.md` §16.
enum DonationStatus {
  draft,
  pendingCheck,
  live,
  allocated,
  collected,
  reallocated,
  unfulfilled,
  cancelled,
  rejected;

  /// Legal next states from this one. Anything not listed is not a
  /// transition the app (or a malformed server payload) should perform.
  Set<DonationStatus> get nextStates => switch (this) {
        DonationStatus.draft => {DonationStatus.pendingCheck, DonationStatus.cancelled},
        DonationStatus.pendingCheck => {DonationStatus.live, DonationStatus.rejected},
        DonationStatus.live => {
            DonationStatus.allocated,
            DonationStatus.cancelled,
            DonationStatus.unfulfilled,
          },
        DonationStatus.allocated => {
            DonationStatus.collected,
            DonationStatus.reallocated,
          },
        DonationStatus.reallocated => {
            DonationStatus.allocated,
            DonationStatus.unfulfilled,
          },
        DonationStatus.collected => const {},
        DonationStatus.unfulfilled => const {},
        DonationStatus.cancelled => const {},
        DonationStatus.rejected => const {},
      };

  bool canTransitionTo(DonationStatus next) => nextStates.contains(next);

  /// Whether this donation is still someone's active concern — i.e. it
  /// belongs in a "live"/"in progress" list rather than history.
  bool get isActive => this == DonationStatus.pendingCheck ||
      this == DonationStatus.live ||
      this == DonationStatus.allocated ||
      this == DonationStatus.reallocated;
}
