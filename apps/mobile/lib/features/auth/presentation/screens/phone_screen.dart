import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_design_system/ss_design_system.dart';

import '../../../../core/providers.dart';
import '../../domain/user_role.dart';
import 'otp_screen.dart';

class PhoneScreen extends ConsumerStatefulWidget {
  const PhoneScreen({super.key, required this.role});

  final UserRole role;

  @override
  ConsumerState<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends ConsumerState<PhoneScreen> {
  final _controller = TextEditingController();
  bool _sending = false;
  String? _error;

  bool get _isValid => RegExp(r'^\d{10}$').hasMatch(_controller.text);

  Future<void> _sendOtp() async {
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).sendOtp(_controller.text);
      if (!mounted) return;
      context.pushNamed(
        'otp',
        extra: OtpScreenArgs(phone: _controller.text, role: widget.role),
      );
    } catch (_) {
      setState(() => _error = 'Could not send the code. Try again.');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(backgroundColor: c.background, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(SsSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Enter your phone number', style: SsTypeScale.h3.copyWith(color: c.onSurface)),
            const SizedBox(height: SsSpacing.sm),
            Text(
              "We'll text you a one-time code to confirm it's you.",
              style: SsTypeScale.body.copyWith(color: c.onSurfaceVariant),
            ),
            const SizedBox(height: SsSpacing.xl),
            SsTextField(
              label: '10-digit mobile number',
              controller: _controller,
              keyboardType: TextInputType.phone,
              prefixIcon: SsIcons.phone,
              errorText: _error,
              autofocus: true,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: SsSpacing.xl),
            SsButton.primary(
              label: 'Send code',
              expand: true,
              isLoading: _sending,
              onPressed: _isValid && !_sending ? _sendOtp : null,
            ),
          ],
        ),
      ),
    );
  }
}
