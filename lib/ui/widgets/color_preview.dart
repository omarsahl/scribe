import 'package:flutter/material.dart';
import 'package:kanban/style/animation.dart';
import 'package:kanban/utils/color_utils.dart';

class ColorPreviewWidget extends StatelessWidget {
  const ColorPreviewWidget({
    required this.color,
    this.constraints,
    this.borderRadius = const BorderRadius.all(Radius.circular(5)),
    this.selected = false,
    this.onTap,
    super.key,
  });

  final Color color;
  final BorderRadius borderRadius;
  final BoxConstraints? constraints;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            constraints: constraints,
            decoration: ShapeDecoration(
              color: color,
              shape: RoundedRectangleBorder(
                borderRadius: borderRadius,
              ),
            ),
          ),
          AnimatedScale(
            curve: Curves.ease,
            scale: selected ? 1 : 0,
            duration: defaultAnimationDuration,
            child: Icon(
              Icons.done,
              color: color.isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
