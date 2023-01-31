import 'package:flutter/material.dart';
import 'package:kanban/data/model/async/async_result.dart';
import 'package:kanban/utils/snack_bar_ext.dart';

extension WidgetStateMobXReaction on State {
  void showSnackBarOnAsyncResultChanges<T>({
    required AsyncResult4<T> result,
    required String Function(T) successMessage,
    void Function(T)? onSuccess,
    String Function(dynamic)? errorMessage,
  }) {
    result.whenOrNull(
      success: (data) {
        context.showSuccessSnackBar(successMessage(data));
        onSuccess?.call(data);
      },
      error: (e, _) {
        if (errorMessage != null) {
          context.showErrorSnackBar(errorMessage(e));
        }
      },
    );
  }
}
