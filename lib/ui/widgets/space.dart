import 'package:flutter/cupertino.dart';

abstract class _Space extends StatelessWidget {
  const _Space(this.size, this.sliver, {super.key});

  final double size;
  final bool sliver;

  @protected
  SizedBox box();

  @override
  Widget build(BuildContext context) {
    Widget child = box();
    if (sliver) {
      child = SliverToBoxAdapter(child: child);
    }
    return child;
  }
}

class HSpace extends _Space {
  const HSpace(double size, {Key? key}) : super(size, false, key: key);

  const HSpace.sliver(double size, {Key? key}) : super(size, true, key: key);

  @override
  SizedBox box() => SizedBox(width: size);
}

class VSpace extends _Space {
  const VSpace(double size, {Key? key}) : super(size, false, key: key);

  const VSpace.sliver(double size, {Key? key}) : super(size, true, key: key);

  @override
  SizedBox box() => SizedBox(height: size);
}
