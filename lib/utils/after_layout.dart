import 'package:flutter/widgets.dart';

mixin AfterLayoutMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.endOfFrame.then(
      (_) => afterFirstLayout(context),
    );
  }

  void afterFirstLayout(BuildContext context);
}

void executeAtEndOfFrame<R, T>(VoidCallback action) {
  WidgetsBinding.instance.endOfFrame.then((_) => action());
}
