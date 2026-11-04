
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ss_design_system/ss_design_system.dart';

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
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _organizationController = TextEditingController();
  final _registrationController = TextEditingController();

  String? _certificatePath;
  String? _certificateName;

  bool _hasError = false;

  bool get _isNgo => widget.role == UserRole.ngo;

  bool get _isValid {
    final basicValid = _nameController.text.trim().isNotEmpty &&
        _emailController.text.contains('@') &&
        _emailController.text.contains('.');

    if (!basicValid) return false;

    if (_isNgo) {
      return _organizationController.text.trim().isNotEmpty &&
          _registrationController.text.trim().isNotEmpty &&
          _certificatePath != null;
    }

    return true;
  }

  Future<void> _pickCertificate() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result == null) return;

      final file = result.files.single;

      if (file.size > 5 * 1024 * 1024) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Certificate must be 5 MB or smaller.'),
          ),
        );
        return;
      }

      if (file.path == null) {
        throw Exception('Unable to access the selected file.');
      }

      setState(() {
        _certificatePath = file.path;
        _certificateName = file.name;
        _hasError = false;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to select certificate: $e')),
      );
    }
  }

  void _proceedToPassword() {
    if (!_isValid) {
      setState(() => _hasError = true);
      return;
    }

    context.pushNamed(
      'otp',
      extra: OtpScreenArgs(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        role: widget.role,
        organizationName:
            _isNgo ? _organizationController.text.trim() : null,
        registrationNumber:
            _isNgo ? _registrationController.text.trim() : null,
        certificatePath: _isNgo ? _certificatePath : null,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _organizationController.dispose();
    _registrationController.dispose();
    super.dispose();
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
                    _isNgo
                        ? 'Enter your contact and organization details to get started.'
                        : 'Enter your name and email to get started.',
                    style: SsTypeScale.body.copyWith(
                      color: c.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: SsSpacing.xl),

                  SsTextField(
                    label: _isNgo ? 'Contact Person Name' : 'Full Name',
                    controller: _nameController,
                    autofocus: true,
                    errorText: _hasError &&
                            _nameController.text.trim().isEmpty
                        ? 'Please enter your name'
                        : null,
                    onChanged: (_) => setState(() => _hasError = false),
                  ),

                  const SizedBox(height: SsSpacing.md),

                  SsTextField(
                    label: 'Email Address',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    errorText: _hasError &&
                            (!_emailController.text.contains('@') ||
                                !_emailController.text.contains('.'))
                        ? 'Please enter a valid email'
                        : null,
                    onChanged: (_) => setState(() => _hasError = false),
                  ),

                  if (_isNgo) ...[
                    const SizedBox(height: SsSpacing.md),
                    SsTextField(
                      label: 'Organization Name',
                      controller: _organizationController,
                      errorText: _hasError &&
                              _organizationController.text.trim().isEmpty
                          ? 'Please enter organization name'
                          : null,
                      onChanged: (_) => setState(() => _hasError = false),
                    ),

                    const SizedBox(height: SsSpacing.md),
                    SsTextField(
                      label: 'Registration Number',
                      controller: _registrationController,
                      errorText: _hasError &&
                              _registrationController.text.trim().isEmpty
                          ? 'Please enter registration number'
                          : null,
                      onChanged: (_) => setState(() => _hasError = false),
                    ),

                    const SizedBox(height: SsSpacing.md),
                    OutlinedButton.icon(
                      onPressed: _pickCertificate,
                      icon: const Icon(Icons.upload_file),
                      label: Text(
                        _certificateName ?? 'Upload NGO Certificate',
                      ),
                    ),

                    if (_hasError && _certificatePath == null) ...[
                      const SizedBox(height: SsSpacing.xs),
                      Text(
                        'Please upload your NGO certificate',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ],

                    const SizedBox(height: SsSpacing.xs),
                    Text(
                      'Accepted formats: PDF, JPG and PNG (maximum 5 MB).',
                      style: SsTypeScale.small.copyWith(
                        color: c.onSurfaceVariant,
                      ),
                    ),
                  ],

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
