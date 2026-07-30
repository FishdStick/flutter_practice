import 'package:flutter/material.dart';

class DialogUtils {
  static Future<bool> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'Delete',
    String cancelText = 'Cancel',
    bool isDangerous = true,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(cancelText)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              confirmText,
              style: TextStyle(color: isDangerous ? Colors.red : Colors.blue),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
