import 'package:flutter/material.dart';
import 'package:kanban/style/shapes.dart';
import 'package:kanban/utils/context_ext.dart';

Future<void> newShowDialog(BuildContext context, Widget child) {
  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: Shapes.dialogShape,
        clipBehavior: Clip.hardEdge,
        insetPadding: const EdgeInsets.all(25),
        backgroundColor: context.theme.colorScheme.surface,
        child: child,
      );
    },
  );
}
