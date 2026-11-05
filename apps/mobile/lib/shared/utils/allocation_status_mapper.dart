import 'package:ss_design_system/ss_design_system.dart';

/// Presentation for backend allocation (NGO request) statuses.
///
/// Source of truth: `status` enum in apps/backend/models/Allocation.js.
abstract final class AllocationStatusView {
  /// Statuses where the request is still in progress.
  static const activeStatuses = {
    'queued',
    'awaiting_ngo_confirmation',
    'pending_donor',
    'approved',
  };

  static bool isActive(String status) => activeStatuses.contains(status);

  static SsStatus ssStatus(String status) => switch (status) {
        'queued' => SsStatus.pendingCheck,
        'awaiting_ngo_confirmation' => SsStatus.urgent,
        'pending_donor' => SsStatus.pendingCheck,
        'approved' => SsStatus.allocated,
        'collected' => SsStatus.collected,
        'rejected' => SsStatus.rejected,
        'declined' => SsStatus.cancelled,
        'cancelled' => SsStatus.cancelled,
        'expired' => SsStatus.unfulfilled,
        _ => SsStatus.draft,
      };

  static String label(String status) => switch (status) {
        'queued' => 'In queue',
        'awaiting_ngo_confirmation' => 'Action needed',
        'pending_donor' => 'Awaiting donor',
        'approved' => 'Approved',
        'collected' => 'Collected',
        'rejected' => 'Rejected',
        'declined' => 'Declined',
        'cancelled' => 'Cancelled',
        'expired' => 'Expired',
        _ => status,
      };
}
