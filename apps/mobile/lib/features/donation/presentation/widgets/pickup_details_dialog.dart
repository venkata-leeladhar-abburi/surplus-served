import 'package:flutter/material.dart';

/// What the donor shares with the NGO when approving a request.
class PickupDetails {
  const PickupDetails({
    required this.address,
    required this.phone,
    this.contactName,
  });

  final String address;
  final String phone;
  final String? contactName;
}

/// Same rules as the backend (allocationController.approveAllocation).
String? validatePickupAddress(String value) {
  final v = value.trim();
  if (v.length < 10) return 'Enter the complete address (house, street, area).';
  if (v.length > 300) return 'Address must be 300 characters or fewer.';
  return null;
}

String? validateContactPhone(String value) {
  final digits = value.replaceAll(RegExp(r'[\s-]'), '');
  if (!RegExp(r'^\+?\d{10,13}$').hasMatch(digits)) {
    return 'Enter a valid phone number (10-13 digits).';
  }
  return null;
}

/// Asks the donor for the full pickup address and a contact number before
/// approving an NGO request. Returns null if the donor cancels.
Future<PickupDetails?> showPickupDetailsDialog(
  BuildContext context, {
  required String ngoName,
  required int portions,
  PickupDetails? initial,
}) {
  return showDialog<PickupDetails>(
    context: context,
    builder: (_) => _PickupDetailsDialog(
      ngoName: ngoName,
      portions: portions,
      initial: initial,
    ),
  );
}

class _PickupDetailsDialog extends StatefulWidget {
  const _PickupDetailsDialog({
    required this.ngoName,
    required this.portions,
    this.initial,
  });

  final String ngoName;
  final int portions;
  final PickupDetails? initial;

  @override
  State<_PickupDetailsDialog> createState() => _PickupDetailsDialogState();
}

class _PickupDetailsDialogState extends State<_PickupDetailsDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _address = TextEditingController(text: widget.initial?.address);
  late final _phone = TextEditingController(text: widget.initial?.phone);
  late final _name = TextEditingController(text: widget.initial?.contactName);

  @override
  void dispose() {
    _address.dispose();
    _phone.dispose();
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final name = _name.text.trim();

    Navigator.of(context).pop(
      PickupDetails(
        address: _address.text.trim(),
        phone: _phone.text.replaceAll(RegExp(r'[\s-]'), ''),
        contactName: name.isEmpty ? null : name,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Approve request'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${widget.ngoName} will receive ${widget.portions} portion(s). '
                'Only this NGO will see the address and phone below.',
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('pickupAddressField'),
                controller: _address,
                autofocus: widget.initial == null,
                maxLines: 3,
                maxLength: 300,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Complete pickup address',
                  hintText: 'House / flat, street, landmark, area, city',
                ),
                validator: (v) => validatePickupAddress(v ?? ''),
              ),
              TextFormField(
                key: const Key('contactPhoneField'),
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Contact phone number',
                ),
                validator: (v) => validateContactPhone(v ?? ''),
              ),
              TextFormField(
                key: const Key('contactNameField'),
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Contact person (optional)',
                  helperText: 'Defaults to your account name',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('confirmApproveButton'),
          onPressed: _submit,
          child: const Text('Approve'),
        ),
      ],
    );
  }
}
