import 'package:ss_design_system/ss_design_system.dart';

import '../../core/l10n/app_localizations.dart';
import '../../features/donation/domain/donation_status.dart';

/// The one place `DonationStatus` (domain, no Flutter) becomes `SsStatus`
/// (presentation — colour, icon, label). Per `ARCHITECTURE.md` §5: the
/// state machine is domain, `SsStatus` carries only presentation concerns.
extension DonationStatusPresentation on DonationStatus {
  SsStatus get ssStatus => switch (this) {
    DonationStatus.draft => SsStatus.draft,
    DonationStatus.pendingCheck => SsStatus.pendingCheck,
    DonationStatus.live => SsStatus.live,
    DonationStatus.allocated => SsStatus.allocated,
    DonationStatus.collected => SsStatus.collected,
    DonationStatus.reallocated => SsStatus.reallocated,
    DonationStatus.unfulfilled => SsStatus.unfulfilled,
    DonationStatus.cancelled => SsStatus.cancelled,
    DonationStatus.rejected => SsStatus.rejected,
  };

  /// `SsStatus.labelEn` is baked into the design-system token and is always
  /// English — this is the localized label every `SsStatusBadge`/
  /// `SsDonationCard` call site should pass instead.
  String label(AppLocalizations l10n) => switch (this) {
    DonationStatus.draft => l10n.statusDraft,
    DonationStatus.pendingCheck => l10n.statusPendingCheck,
    DonationStatus.live => l10n.statusLive,
    DonationStatus.allocated => l10n.statusAllocated,
    DonationStatus.collected => l10n.statusCollected,
    DonationStatus.reallocated => l10n.statusReallocated,
    DonationStatus.unfulfilled => l10n.statusUnfulfilled,
    DonationStatus.cancelled => l10n.statusCancelled,
    DonationStatus.rejected => l10n.statusRejected,
  };
}
