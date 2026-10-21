import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_design_system/ss_design_system.dart';

import '../../../../core/providers.dart';
import '../../../../shared/widgets/connectivity_banner.dart';
import '../../domain/user_role.dart';

class OtpScreenArgs {
  const OtpScreenArgs({required this.phone, required this.role});
  final String phone; // Reused variable name for email
  final UserRole role;
}

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.args});

  final OtpScreenArgs args;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _controller = TextEditingController();
  bool _verifying = false;
  bool _hasError = false;

  Future<void> _authenticate() async {
    setState(() {
      _verifying = true;
      _hasError = false;
    });
    try {
      // Calls backend login/register endpoint via your repository provider
      final session = await ref
          .read(authRepositoryProvider)
          .verifyOtp( // Mapped to email/password backend call in repository
            phone: widget.args.phone,
            otp: _controller.text,
            role: widget.args.role,
          );
      ref.read(sessionProvider.notifier).signIn(session);
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
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
                    'Enter your Password',
                    style: SsTypeScale.h3.copyWith(color: c.onSurface),
                  ),
                  const SizedBox(height: SsSpacing.sm),
                  Text(
                    'Account: ${widget.args.phone}',
                    style: SsTypeScale.body.copyWith(color: c.onSurfaceVariant),
                  ),
                  const SizedBox(height: SsSpacing.xl),
                  SsTextField(
                    label: 'Password (min 6 characters)',
                    controller: _controller,
                    obscureText: true,
                    errorText: _hasError ? 'Invalid password or connection error' : null,
                    autofocus: true,
                    onChanged: (_) => setState(() => _hasError = false),
                  ),
                  const SizedBox(height: SsSpacing.xl),
                  SsButton.primary(
                    label: 'Login / Register',
                    expand: true,
                    isLoading: _verifying,
                    onPressed: _controller.text.length >= 6 && !_verifying
                        ? _authenticate
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
