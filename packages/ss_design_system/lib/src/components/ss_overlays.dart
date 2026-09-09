import 'package:flutter/material.dart';

import '../icons/ss_icon.dart';
import '../icons/ss_icons.g.dart';
import '../theme/ss_colors.dart';
import '../tokens/tokens.g.dart';
import 'ss_button.dart';

/// §06.7 Modals — the confirmation step that stops accidental requests.
///
/// ```dart
/// final ok = await SsDialog.confirm(
///   context,
///   title: 'Request Food?',
///   message: 'This will send a request to Green Bites Café.',
///   confirmLabel: 'Request',
/// );
/// ```
abstract final class SsDialog {
  /// Returns true if the user confirmed, false or null otherwise.
  static Future<bool?> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    SsIconData icon = SsIcons.leaf,
    bool destructive = false,
    bool dismissible = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: dismissible,
      builder: (context) {
        final c = context.ssColors;
        return AlertDialog(
          contentPadding: const EdgeInsets.fromLTRB(
            SsSpacing.xl, SsSpacing.xl, SsSpacing.xl, SsSpacing.lg,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(
            SsSpacing.xl, 0, SsSpacing.xl, SsSpacing.xl,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (dismissible)
                Align(
                  alignment: Alignment.topRight,
                  child: SsIconButton(
                    icon: SsIcons.close,
                    tooltip: 'Close',
                    plain: true,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
              Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  color: destructive ? c.errorContainer : c.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: SsIcon(
                  destructive ? SsIcons.alert : icon,
                  size: SsIconSize.lg,
                  color: destructive ? c.onErrorContainer : c.primary,
                ),
              ),
              const SizedBox(height: SsSpacing.lg),
              Text(
                title,
                textAlign: TextAlign.center,
                style: SsTypeScale.h4.copyWith(color: c.onSurface),
              ),
              const SizedBox(height: SsSpacing.sm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: SsTypeScale.body.copyWith(color: c.onSurfaceVariant),
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: SsButton.secondary(
                    label: cancelLabel,
                    onPressed: () => Navigator.of(context).pop(false),
                    expand: true,
                  ),
                ),
                const SizedBox(width: SsSpacing.md),
                Expanded(
                  child: destructive
                      ? SsButton.danger(
                          label: confirmLabel,
                          onPressed: () => Navigator.of(context).pop(true),
                          expand: true,
                        )
                      : SsButton.primary(
                          label: confirmLabel,
                          onPressed: () => Navigator.of(context).pop(true),
                          expand: true,
                        ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// §06.7 Bottom sheet — filters, pickers and anything that needs room.
abstract final class SsSheet {
  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Widget child,
    String? primaryActionLabel,
    VoidCallback? onPrimaryAction,
    String? secondaryActionLabel,
    VoidCallback? onSecondaryAction,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      useSafeArea: true,
      builder: (context) {
        final c = context.ssColors;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  SsSpacing.xl, 0, SsSpacing.md, SsSpacing.md,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: SsTypeScale.h4.copyWith(color: c.onSurface),
                      ),
                    ),
                    if (secondaryActionLabel != null)
                      SsButton.tertiary(
                        label: secondaryActionLabel,
                        onPressed: onSecondaryAction,
                      ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SsSpacing.xl,
                  ),
                  child: child,
                ),
              ),
              if (primaryActionLabel != null)
                Padding(
                  padding: const EdgeInsets.all(SsSpacing.xl),
                  child: SsButton.primary(
                    label: primaryActionLabel,
                    onPressed: onPrimaryAction,
                    expand: true,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// §06.6 Toast — the transient confirmation after an action lands.
///
/// Uses a [SnackBar] so it inherits Flutter's accessibility timing behaviour
/// (it stays visible longer when a screen reader is active).
abstract final class SsToast {
  static void show(
    BuildContext context, {
    required String message,
    SsToastTone tone = SsToastTone.success,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final c = context.ssColors;
    final (icon, color) = switch (tone) {
      SsToastTone.success => (SsIcons.check, c.success),
      SsToastTone.info => (SsIcons.info, c.info),
      SsToastTone.warning => (SsIcons.alert, c.warning),
      SsToastTone.error => (SsIcons.alert, c.error),
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SsIcon(icon, size: SsIconSize.sm, color: color),
              const SizedBox(width: SsSpacing.md),
              Expanded(child: Text(message)),
            ],
          ),
          action: actionLabel == null
              ? null
              : SnackBarAction(
                  label: actionLabel,
                  textColor: c.highlight,
                  onPressed: onAction ?? () {},
                ),
        ),
      );
  }
}

enum SsToastTone { success, info, warning, error }
