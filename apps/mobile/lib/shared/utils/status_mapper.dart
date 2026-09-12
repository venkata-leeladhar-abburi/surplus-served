import 'package:ss_design_system/ss_design_system.dart';

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
}
