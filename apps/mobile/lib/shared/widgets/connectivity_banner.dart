import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_design_system/ss_design_system.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/network/connectivity_provider.dart';

/// A slim, non-blocking banner — the feed, history and everything else
/// underneath it stays fully visible and tappable. Cold start and any
/// transient stream error both read as "online": a false offline banner
/// is a worse first impression than a missed one, and every repository
/// today is fixture-backed anyway (nothing actually depends on the
/// network yet).
class ConnectivityBanner extends ConsumerWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isOnline = ref
        .watch(connectivityProvider)
        .maybeWhen(data: (online) => online, orElse: () => true);

    if (isOnline) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SsSpacing.lg,
        SsSpacing.md,
        SsSpacing.lg,
        0,
      ),
      child: SsAlert(
        tone: SsAlertTone.warning,
        message: l10n.offlineBannerMessage,
      ),
    );
  }
}
