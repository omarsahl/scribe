import 'package:flutter/material.dart';
import 'package:kanban/style/borders.dart';
import 'package:kanban/utils/color_utils.dart';
import 'package:kanban/utils/context_ext.dart';

class BoardLabel extends StatelessWidget {
  const BoardLabel({
    required this.label,
    required this.color,
    this.onTap,
    this.labelStyle,
    this.borderRadius = Borders.roundedAll10,
    this.padding = const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
    super.key,
  });

  final String label;
  final Color color;
  final VoidCallback? onTap;
  final TextStyle? labelStyle;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Padding(
          padding: padding,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: labelStyle ??
                context.theme.textTheme.titleMedium?.copyWith(
                  color: color.isDark ? Colors.white : Colors.black,
                ),
          ),
        ),
      ),
    );
  }
}
