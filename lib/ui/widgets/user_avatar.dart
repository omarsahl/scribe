import 'package:flutter/material.dart';
import 'package:kanban/utils/context_ext.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    required this.name,
    this.imageUrl,
    this.onTap,
    this.radius = 25,
    super.key,
  });

  final String name;
  final double radius;
  final String? imageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget widget;
    if (imageUrl != null) {
      widget = CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(imageUrl!),
      );
    } else {
      widget = CircleAvatar(
        backgroundColor: context.theme.colorScheme.primary,
        child: Text(
          _initials,
          style: context.theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.theme.colorScheme.onPrimary,
          ),
        ),
      );
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        widget,
        Positioned.fill(
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              radius: radius,
              customBorder: const CircleBorder(),
            ),
          ),
        ),
      ],
    );
  }

  String get _initials {
    final parts = name.split(' ');
    if (parts.length < 2) {
      return parts[0][0];
    }
    return parts[0][0] + parts[1][0];
  }
}
