
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_design_system/ss_design_system.dart';

import '../../../../core/providers.dart';
import '../../../../shared/widgets/connectivity_banner.dart';

class EnterPickupCodeScreen extends ConsumerStatefulWidget {
  const EnterPickupCodeScreen({
    super.key,
    required this.allocationId,
  });

  final String allocationId;

  @override
  ConsumerState<EnterPickupCodeScreen> createState() =>
      _EnterPickupCodeScreenState();
}

class _EnterPickupCodeScreenState
    extends ConsumerState<EnterPickupCodeScreen> {
  final _controller = TextEditingController();

  bool _checking = false;
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _controller.text.trim();

    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      setState(() {
        _errorMessage = 'Please enter a valid six-digit pickup code.';
      });
      return;
    }

    setState(() {
      _checking = true;
      _errorMessage = null;
    });

    try {
      await ref.read(allocationRepositoryProvider).verifyPickupCode(
            allocationId: widget.allocationId,
            code: code,
          );

      if (!mounted) return;

      context.pop(true);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _checking = false);
      }
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
          onPressed: _checking ? null : () => context.pop(),
        ),
        title: Text(
          'Verify pickup',
          style: SsTypeScale.h3.copyWith(color: c.onSurface),
        ),
      ),
      body: Column(
        children: [
          const ConnectivityBanner(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(SsSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: SsSpacing.lg),
                  Icon(
                    Icons.verified_user_outlined,
                    size: 64,
                    color: c.primary,
                  ),
                  const SizedBox(height: SsSpacing.lg),
                  Text(
                    'Confirm food pickup',
                    textAlign: TextAlign.center,
                    style: SsTypeScale.h3.copyWith(
                      color: c.onSurface,
                    ),
                  ),
                  const SizedBox(height: SsSpacing.sm),
                  Text(
                    'Ask the NGO to share the six-digit pickup code. '
                    'Enter that code here to confirm that the food '
                    'has been collected.',
                    textAlign: TextAlign.center,
                    style: SsTypeScale.body.copyWith(
                      color: c.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: SsSpacing.xxl),
                  SsTextField(
                    label: 'Six-digit pickup code',
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    autofocus: true,
                    errorText: _errorMessage,
                    onChanged: (_) {
                      setState(() {
                        _errorMessage = null;
                      });
                    },
                  ),
                  const SizedBox(height: SsSpacing.xl),
                  SsButton.primary(
                    label: 'Verify pickup',
                    expand: true,
                    isLoading: _checking,
                    onPressed: _controller.text.length == 6 && !_checking
                        ? _submit
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
