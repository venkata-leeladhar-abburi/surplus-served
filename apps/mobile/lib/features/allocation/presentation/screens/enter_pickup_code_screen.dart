import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_design_system/ss_design_system.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/providers.dart';
import '../../domain/allocation_repository.dart';

/// §12's entire proof mechanism for v1: the NGO reads the 4-digit code off
/// the donor's screen and enters it here. No photo, no signature, no GPS.
class EnterPickupCodeScreen extends ConsumerStatefulWidget {
  const EnterPickupCodeScreen({super.key, required this.donationId});

  final String donationId;

  @override
  ConsumerState<EnterPickupCodeScreen> createState() => _EnterPickupCodeScreenState();
}

class _EnterPickupCodeScreenState extends ConsumerState<EnterPickupCodeScreen> {
  final _controller = TextEditingController();
  bool _checking = false;
  bool _hasError = false;

  Future<void> _submit() async {
    setState(() {
      _checking = true;
      _hasError = false;
    });
    final result = await ref.read(allocationRepositoryProvider).enterPickupCode(
          donationId: widget.donationId,
          code: _controller.text,
        );
    if (!mounted) return;
    setState(() => _checking = false);
    if (result == CodeEntryResult.success) {
      context.goNamed('receiverHandoverSuccess', pathParameters: {'id': widget.donationId});
    } else {
      setState(() => _hasError = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        elevation: 0,
        leading: IconButton(
          icon: SsIcon(SsIcons.arrowLeft, color: c.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(SsSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.receiverEnterCodeTitle, style: SsTypeScale.h3.copyWith(color: c.onSurface)),
            const SizedBox(height: SsSpacing.sm),
            Text(
              l10n.receiverEnterCodeSubtitle,
              style: SsTypeScale.body.copyWith(color: c.onSurfaceVariant),
            ),
            const SizedBox(height: SsSpacing.xxl),
            SsTextField(
              label: l10n.donorPickupCodeLabel,
              controller: _controller,
              keyboardType: TextInputType.number,
              maxLength: 4,
              errorText: _hasError ? l10n.receiverEnterCodeError : null,
              autofocus: true,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: SsSpacing.xl),
            SsButton.primary(
              label: l10n.receiverConfirmCollectedCta,
              expand: true,
              isLoading: _checking,
              onPressed: _controller.text.length == 4 && !_checking ? _submit : null,
            ),
          ],
        ),
      ),
    );
  }
}
