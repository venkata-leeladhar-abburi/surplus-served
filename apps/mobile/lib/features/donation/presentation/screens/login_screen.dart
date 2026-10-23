import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_design_system/ss_design_system.dart';

import '../../../../core/providers.dart';
import '../../../../shared/widgets/connectivity_banner.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super me});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _hasError = false;
  String _errorMessage = 'Invalid email or password';

  bool get _isValid =>
      _emailController.text.contains('@') &&
      _passwordController.text.length >= 6;

  Future<void> _handleLogin() async {
    setState(() {
      _loading = true;
      _hasError = false;
    });

    try {
      final session = await ref.read(authRepositoryProvider).login(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      ref.read(sessionProvider.notifier).signIn(session);
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
                    'Welcome Back',
                    style: SsTypeScale.h3.copyWith(color: c.onSurface),
                  ),
                  const SizedBox(height: SsSpacing.sm),
                  Text(
                    'Log in with your email and password.',
                    style: SsTypeScale.body.copyWith(color: c.onSurfaceVariant),
                  ),
                  const SizedBox(height: SsSpacing.xl),
                  SsTextField(
                    label: 'Email Address',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) => setState(() => _hasError = false),
                  ),
                  const SizedBox(height: SsSpacing.md),
                  SsTextField(
                    label: 'Password',
                    controller: _passwordController,
                    obscureText: true,
                    errorText: _hasError ? _errorMessage : null,
                    onChanged: (_) => setState(() => _hasError = false),
                  ),
                  const SizedBox(height: SsSpacing.xl),
                  SsButton.primary(
                    label: 'Login',
                    expand: true,
                    isLoading: _loading,
                    onPressed: _isValid && !_loading ? _handleLogin : null,
                  ),
                  const SizedBox(height: SsSpacing.md),
                  TextButton(
                    onPressed: () => context.pushNamed('phone'), // Or navigate back to registration
                    child: const Text('Don\'t have an account? Sign Up'),
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
