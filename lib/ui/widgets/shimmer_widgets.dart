import 'package:flutter/material.dart';
import 'package:kanban/utils/context_ext.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerCircle extends StatelessWidget {
  final double radius;

  const ShimmerCircle({Key? key, required this.radius}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2.0,
      height: radius * 2.0,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
    );
  }
}

class ShimmerRect extends StatelessWidget {
  final double? width;
  final double height;
  final double cornerRadius;
  final EdgeInsets margin;

  const ShimmerRect({
    Key? key,
    required this.height,
    this.width = double.infinity,
    this.cornerRadius = 5.0,
    this.margin = EdgeInsets.zero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(cornerRadius))),
      ),
    );
  }
}

class ShimmerContainer extends StatelessWidget {
  const ShimmerContainer({required this.child, Key? key}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final baseColor = theme.colorScheme.onSurface.withOpacity(0.1);
    final highlightColor = theme.colorScheme.onSurface.withOpacity(0.25);
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: child,
    );
  }
}

Widget shimmerOf({
  required Widget child,
  ShimmerDirection direction = ShimmerDirection.ltr,
  int loop = 0,
  bool enabled = true,
  Color baseColor = const Color(0xFFE0E0E0),
  Color highlightColor = const Color(0xFFF5F5F5),
}) {
  return Shimmer.fromColors(
    loop: loop,
    enabled: enabled,
    direction: direction,
    baseColor: baseColor,
    highlightColor: highlightColor,
    child: child,
  );
}
