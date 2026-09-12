import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ss_design_system/ss_design_system.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/providers.dart';
import '../../domain/user_role.dart';

class OtpScreenArgs {
  const OtpScreenArgs({required this.phone, required this.role});
  final String phone;
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

  Future<void> _verify() async {
    setState(() {
      _verifying = true;
      _hasError = false;
    });
    try {
      final session = await ref.read(authRepositoryProvider).verifyOtp(
            phone: widget.args.phone,
            otp: _controller.text,
            role: widget.args.role,
          );
      ref.read(sessionProvider.notifier).signIn(session);
      // No explicit navigation — the router's redirect picks the role's
      // home route up as soon as sessionProvider changes.
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(backgroundColor: c.background, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(SsSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.authOtpTitle, style: SsTypeScale.h3.copyWith(color: c.onSurface)),
            const SizedBox(height: SsSpacing.sm),
            Text(
              l10n.authOtpSubtitle(widget.args.phone),
              style: SsTypeScale.body.copyWith(color: c.onSurfaceVariant),
            ),
            const SizedBox(height: SsSpacing.xl),
            SsTextField(
              label: l10n.authOtpCodeLabel,
              controller: _controller,
              keyboardType: TextInputType.number,
              maxLength: 4,
              errorText: _hasError ? l10n.authOtpError : null,
              autofocus: true,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: SsSpacing.xl),
            SsButton.primary(
              label: l10n.authVerifyCta,
              expand: true,
              isLoading: _verifying,
              onPressed: _controller.text.length == 4 && !_verifying ? _verify : null,
            ),
          ],
        ),
      ),
    );
  }
}
