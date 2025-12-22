import 'package:flutter/material.dart';

import 'string_extensions.dart';

extension ContextExtensions on BuildContext {
  Future<T?> showBottomSheet<T>({
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: this,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => child,
    );
  }

  Future<bool?> showConfirmationBottomSheet({
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    Color? confirmColor,
    bool isDangerous = false,
  }) {
    final theme = Theme.of(this);

    return showBottomSheet<bool>(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(this).pop(false),
                    child: Text(cancelText ?? 'cancel'.translate()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(this).pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          isDangerous ? theme.colorScheme.error : confirmColor,
                    ),
                    child: Text(confirmText ?? 'confirm'.translate()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
