import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// What the donor shares with the NGO when approving a request.
class PickupDetails {
  const PickupDetails({
    required this.address,
    required this.phone,
    this.contactName,
    this.latitude,
    this.longitude,
  });

  final String address;
  final String phone;
  final String? contactName;

  /// Optional exact pickup point (GPS), used by the NGO for directions.
  final double? latitude;
  final double? longitude;
}

/// Gets the phone's current position. Throws an [Exception] with a message
/// the donor can act on (location off, permission denied).
typedef PickupLocationFetcher = Future<({double latitude, double longitude})>
    Function();

Future<({double latitude, double longitude})> currentDeviceLocation() async {
  if (!await Geolocator.isLocationServiceEnabled()) {
    throw Exception('Turn on location on your phone and try again.');
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    throw Exception(
      'Location permission was denied. You can still approve with the '
      'address only.',
    );
  }

  final position = await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      timeLimit: Duration(seconds: 20),
    ),
  );

  return (latitude: position.latitude, longitude: position.longitude);
}

/// Overridden in tests so no real GPS is needed.
final pickupLocationFetcherProvider = Provider<PickupLocationFetcher>(
  (ref) => currentDeviceLocation,
);

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
  required PickupLocationFetcher getLocation,
  PickupDetails? initial,
}) {
  return showDialog<PickupDetails>(
    context: context,
    builder: (_) => _PickupDetailsDialog(
      ngoName: ngoName,
      portions: portions,
      getLocation: getLocation,
      initial: initial,
    ),
  );
}

class _PickupDetailsDialog extends StatefulWidget {
  const _PickupDetailsDialog({
    required this.ngoName,
    required this.portions,
    required this.getLocation,
    this.initial,
  });

  final String ngoName;
  final int portions;
  final PickupLocationFetcher getLocation;
  final PickupDetails? initial;

  @override
  State<_PickupDetailsDialog> createState() => _PickupDetailsDialogState();
}

class _PickupDetailsDialogState extends State<_PickupDetailsDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _address = TextEditingController(text: widget.initial?.address);
  late final _phone = TextEditingController(text: widget.initial?.phone);
  late final _name = TextEditingController(text: widget.initial?.contactName);

  late double? _latitude = widget.initial?.latitude;
  late double? _longitude = widget.initial?.longitude;
  bool _locating = false;
  String? _locationError;

  Future<void> _useCurrentLocation() async {
    setState(() {
      _locating = true;
      _locationError = null;
    });

    try {
      final point = await widget.getLocation();
      if (!mounted) return;
      setState(() {
        _latitude = point.latitude;
        _longitude = point.longitude;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _locationError = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

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
        latitude: _latitude,
        longitude: _longitude,
      ),
    );
  }

  /// Optional: pin the exact pickup spot so the NGO gets accurate directions.
  Widget _buildLocationRow(BuildContext context) {
    final theme = Theme.of(context);
    final pinned = _latitude != null && _longitude != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          key: const Key('useLocationButton'),
          onPressed: _locating ? null : _useCurrentLocation,
          icon: _locating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(pinned ? Icons.location_on : Icons.my_location),
          label: Text(
            pinned ? 'Update pinned location' : 'Use my current location',
          ),
        ),
        const SizedBox(height: 4),
        if (_locationError != null)
          Text(
            _locationError!,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.error),
          )
        else if (pinned)
          Row(
            children: [
              Expanded(
                child: Text(
                  'Exact location pinned. The NGO gets directions to this '
                  'spot.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
              TextButton(
                key: const Key('clearLocationButton'),
                onPressed: () => setState(() {
                  _latitude = null;
                  _longitude = null;
                }),
                child: const Text('Remove'),
              ),
            ],
          )
        else
          Text(
            'Optional. Stand at the pickup spot and tap this so the NGO '
            'gets exact directions.',
            style: theme.textTheme.bodySmall,
          ),
      ],
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
              const SizedBox(height: 12),
              _buildLocationRow(context),
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
