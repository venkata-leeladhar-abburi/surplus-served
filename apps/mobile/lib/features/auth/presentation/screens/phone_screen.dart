import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_design_system/ss_design_system.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/providers.dart';
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
  bool _sending = false;
  bool _hasError = false;

  bool get _isValid => RegExp(r'^\d{10}$').hasMatch(_controller.text);

  Future<void> _sendOtp() async {
    setState(() {
      _sending = true;
      _hasError = false;
    });
    try {
      await ref.read(authRepositoryProvider).sendOtp(_controller.text);
      if (!mounted) return;
      context.pushNamed(
        'otp',
        extra: OtpScreenArgs(phone: _controller.text, role: widget.role),
      );
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;
    final l10n = AppLocalizations.of(context)!;
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
                    l10n.authPhoneTitle,
                    style: SsTypeScale.h3.copyWith(color: c.onSurface),
                  ),
                  const SizedBox(height: SsSpacing.sm),
                  Text(
                    l10n.authPhoneSubtitle,
                    style: SsTypeScale.body.copyWith(color: c.onSurfaceVariant),
                  ),
                  const SizedBox(height: SsSpacing.xl),
                  SsTextField(
                    label: l10n.authPhoneHint,
                    controller: _controller,
                    keyboardType: TextInputType.phone,
                    prefixIcon: SsIcons.phone,
                    errorText: _hasError ? l10n.authPhoneError : null,
                    autofocus: true,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: SsSpacing.xl),
                  SsButton.primary(
                    label: l10n.authSendCodeCta,
                    expand: true,
                    isLoading: _sending,
                    onPressed: _isValid && !_sending ? _sendOtp : null,
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
