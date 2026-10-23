import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_design_system/ss_design_system.dart';

import '../../../../shared/widgets/connectivity_banner.dart';
import '../../domain/user_role.dart';
import 'otp_screen.dart'; // We will use this to pass args to the password screen

class PhoneScreen extends ConsumerStatefulWidget {
  const PhoneScreen({super.key, required this.role});

  final UserRole role;

  @override
  ConsumerState<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends ConsumerState<PhoneScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _hasError = false;

  bool get _isValid =>
      _nameController.text.trim().isNotEmpty &&
      _emailController.text.contains('@') &&
      _emailController.text.contains('.');

  void _proceedToPassword() {
    if (!_isValid) {
      setState(() => _hasError = true);
      return;
    }
    context.pushNamed(
      'otp', // Routes to password screen
      extra: OtpScreenArgs(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        role: widget.role,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ssColors;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(backgroundColor: c.background, elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const ConnectivityBanner(),
            Padding(
              padding: const EdgeInsets.all(SsSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Create Your Profile',
                    style: SsTypeScale.h3.copyWith(color: c.onSurface),
                  ),
                  const SizedBox(height: SsSpacing.sm),
                  Text(
                    'Enter your name and email to get started.',
                    style: SsTypeScale.body.copyWith(color: c.onSurfaceVariant),
                  ),
                  const SizedBox(height: SsSpacing.xl),
                  SsTextField(
                    label: 'Full Name / Organization Name',
                    controller: _nameController,
                    autofocus: true,
                    errorText: _hasError && _nameController.text.trim().isEmpty
                        ? 'Please enter your name'
                        : null,
                    onChanged: (_) => setState(() => _hasError = false),
                  ),
                  const SizedBox(height: SsSpacing.md),
                  SsTextField(
                    label: 'Email Address',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    errorText: _hasError && !_emailController.text.contains('@')
                        ? 'Please enter a valid email'
                        : null,
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
          ],
        ),
      ),
    );
  }
}
