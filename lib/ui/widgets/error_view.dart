import 'package:flutter/material.dart';
import 'package:kanban/utils/context_ext.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({
    this.message,
    this.textStyle,
    this.center = true,
    this.padding = const EdgeInsets.all(16),
    Key? key,
  }) : super(key: key);

  final String? message;
  final TextStyle? textStyle;
  final bool center;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    String msg = message ?? context.localizations.genericErrorMessage;
    Widget widget = Text(
      msg,
      textAlign: TextAlign.center,
      style: context.theme.textTheme.bodyLarge,
    );
    if (padding != null) {
      widget = Padding(padding: padding!, child: widget);
    }
    if (center) {
      widget = Center(child: widget);
    }
    return widget;
  }
}
