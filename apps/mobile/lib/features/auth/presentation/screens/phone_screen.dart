import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_design_system/ss_design_system.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../shared/widgets/connectivity_banner.dart';
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
  bool _hasError = false;

  bool get _isValid => _controller.text.contains('@') && _controller.text.contains('.');

  void _proceedToPassword() {
    if (!_isValid) {
      setState(() => _hasError = true);
      return;
    }
    context.pushNamed(
      'otp',
      extra: OtpScreenArgs(phone: _controller.text.trim(), role: widget.role),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(backgroundColor: c.background, elevation: 0),
      body: Column(
        children: [
          const ConnectivityBanner(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(SsSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Enter your Email',
                    style: SsTypeScale.h3.copyWith(color: c.onSurface),
                  ),
                  const SizedBox(height: SsSpacing.sm),
                  Text(
                    'We will use this email for your account login.',
                    style: SsTypeScale.body.copyWith(color: c.onSurfaceVariant),
                  ),
                  const SizedBox(height: SsSpacing.xl),
                  SsTextField(
                    label: 'Email Address',
                    controller: _controller,
                    keyboardType: TextInputType.emailAddress,
                    errorText: _hasError ? 'Please enter a valid email' : null,
                    autofocus: true,
                    onChanged: (_) => setState(() => _hasError = false),
                  ),
                  const SizedBox(height: SsSpacing.xl),
                  SsButton.primary(
                    label: 'Continue',
                    expand: true,
                    onPressed: _isValid ? _proceedToPassword : null,
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
