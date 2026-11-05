import 'package:flutter/material.dart';

/// Shows a dialog with one text field and returns the entered text,
/// or null if the user cancels.
///
/// [validator] returns an error message to show, or null when valid.
/// The dialog owns its TextEditingController, so it is disposed only after
/// the closing animation finishes.
Future<String?> showTextInputDialog(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  String? label,
  String? helperText,
  String initialText = '',
  TextInputType keyboardType = TextInputType.text,
  int maxLines = 1,
  int? maxLength,
  bool destructive = false,
  String? Function(String value)? validator,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _TextInputDialog(
      title: title,
      confirmLabel: confirmLabel,
      label: label,
      helperText: helperText,
      initialText: initialText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      destructive: destructive,
      validator: validator,
    ),
  );
}

class _TextInputDialog extends StatefulWidget {
  const _TextInputDialog({
    required this.title,
    required this.confirmLabel,
    required this.initialText,
    required this.keyboardType,
    required this.maxLines,
    required this.destructive,
    this.label,
    this.helperText,
    this.maxLength,
    this.validator,
  });

  final String title;
  final String confirmLabel;
  final String? label;
  final String? helperText;
  final String initialText;
  final TextInputType keyboardType;
  final int maxLines;
  final int? maxLength;
  final bool destructive;
  final String? Function(String value)? validator;

  @override
  State<_TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<_TextInputDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialText);
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    final error = widget.validator?.call(value);

    if (error != null) {
      setState(() => _error = error);
      return;
    }

    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: widget.keyboardType,
        maxLines: widget.maxLines,
        maxLength: widget.maxLength,
        decoration: InputDecoration(
          labelText: widget.label,
          helperText: widget.helperText,
          errorText: _error,
        ),
        onSubmitted: widget.maxLines == 1 ? (_) => _submit() : null,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: widget.destructive
              ? FilledButton.styleFrom(backgroundColor: Colors.red)
              : null,
          onPressed: _submit,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
