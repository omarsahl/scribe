import 'package:flutter/material.dart';

class DefaultProgressIndicator extends StatelessWidget {
  const DefaultProgressIndicator({
    this.radius,
    this.color,
    this.strokeWidth = 4,
    this.centered = false,
    super.key,
  });

  const DefaultProgressIndicator.small({
    bool centered = false,
    Color? color,
    Key? key,
  }) : this(
          radius: 12,
          strokeWidth: 2,
          color: color,
          centered: centered,
          key: key,
        );

  final double? radius;
  final Color? color;
  final double strokeWidth;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    Widget widget = CircularProgressIndicator(
      color: color,
      strokeWidth: strokeWidth,
    );
    if (radius != null) {
      widget = SizedBox.square(
        dimension: radius! * 2.0,
        child: widget,
      );
    }
    if (centered) {
      widget = Center(child: widget);
    }
    return widget;
  }
}
