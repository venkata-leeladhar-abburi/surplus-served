import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_design_system/ss_design_system.dart';

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
  String? _error;

  Future<void> _submit() async {
    setState(() {
      _checking = true;
      _error = null;
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
      setState(() => _error = "That code doesn't match. Check with the donor and try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;
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
            Text('Confirm handover', style: SsTypeScale.h3.copyWith(color: c.onSurface)),
            const SizedBox(height: SsSpacing.sm),
            Text(
              'Ask the donor for the 4-digit code shown on their screen.',
              style: SsTypeScale.body.copyWith(color: c.onSurfaceVariant),
            ),
            const SizedBox(height: SsSpacing.xxl),
            SsTextField(
              label: 'Pickup code',
              controller: _controller,
              keyboardType: TextInputType.number,
              maxLength: 4,
              errorText: _error,
              autofocus: true,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: SsSpacing.xl),
            SsButton.primary(
              label: 'Confirm collected',
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
