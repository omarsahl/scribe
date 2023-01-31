import 'package:flutter/material.dart';
import 'package:kanban/ui/widgets/space.dart';
import 'package:kanban/utils/context_ext.dart';

class EmptyListWidget extends StatelessWidget {
  const EmptyListWidget({
    required this.message,
    this.actionWidget,
    super.key,
  });

  final String message;
  final Widget? actionWidget;

  @override
  Widget build(BuildContext context) {
    Widget widget = Text(
      message,
      textAlign: TextAlign.center,
      style: context.theme.textTheme.bodyMedium,
    );
    if (actionWidget != null) {
      widget = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          widget,
          const VSpace(15),
          actionWidget!,
        ],
      );
    }
    return Center(child: widget);
  }
}
