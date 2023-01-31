import 'package:flutter/material.dart';
import 'package:kanban/style/shapes.dart';
import 'package:kanban/utils/context_ext.dart';

extension SnackBarX on BuildContext {
  SnackBar _buildSnackBar({
    required Widget icon,
    required Widget content,
    SnackBarBehavior behavior = SnackBarBehavior.floating,
  }) {
    return SnackBar(
      behavior: behavior,
      shape: Shapes.roundedShape10,
      margin: const EdgeInsets.all(8),
      content: Row(
        children: [
          icon,
          const SizedBox(width: 10),
          Expanded(child: content),
        ],
      ),
    );
  }

  void _showSnackBar(SnackBar snackBar) {
    ScaffoldMessenger.of(this).showSnackBar(snackBar);
  }

  void showSnackBar(String message) {
    _showSnackBar(
      SnackBar(
        content: Text(message),
        shape: Shapes.roundedShape10,
        margin: const EdgeInsets.all(8),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void showSuccessSnackBar(String message) {
    _showSnackBar(
      _buildSnackBar(
        content: Text(message),
        icon: const Icon(Icons.done),
      ),
    );
  }

  void showErrorSnackBar([String? message]) {
    _showSnackBar(
      _buildSnackBar(
        icon: const Icon(Icons.error_outline_rounded, color: Colors.red),
        content: Text(message ?? localizations.genericErrorMessage),
      ),
    );
  }
}
