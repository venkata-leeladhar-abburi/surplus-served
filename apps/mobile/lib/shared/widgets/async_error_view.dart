import 'package:flutter/material.dart';
import 'package:ss_design_system/ss_design_system.dart';

import '../../core/l10n/app_localizations.dart';

/// The one place an async load failure reaches the screen. Two rules that
/// every `.when(error: ...)` branch used to break before this existed:
///
/// 1. Never interpolate the raw exception into user-facing text — `err`
///    is an implementation detail (a stack-trace-bearing Exception object,
///    a Dio error once a real backend lands), not copy. Log it for
///    diagnostics; show the NGO/donor a plain, translated sentence.
/// 2. Give the user a way out. A dead-end error with no retry is the
///    surest way turn a blip into an abandoned donation.
class AsyncErrorView extends StatelessWidget {
  const AsyncErrorView({super.key, required this.error, this.onRetry});

  /// Not rendered — logged only. Kept typed as Object so call sites can
  /// pass whatever `.when(error: (err, _) => ...)` hands them.
  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // A real crash-reporting hook (Sentry, per ARCHITECTURE.md §5) belongs
    // here — this is the single choke point every load failure passes
    // through, so it's the one place that hook needs to be added once.
    debugPrint('AsyncErrorView: $error');

    return Center(
      child: SsEmptyState(
        title: l10n.commonErrorTitle,
        message: l10n.commonErrorMessage,
        illustration: SsIllustrations.somethingWentWrong,
        primaryActionLabel: onRetry == null ? null : l10n.commonRetry,
        onPrimaryAction: onRetry,
      ),
    );
  }
}
