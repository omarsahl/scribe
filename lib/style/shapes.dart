import 'package:flutter/widgets.dart';
import 'package:kanban/style/borders.dart';

class Shapes {
  Shapes._();

  static const OutlinedBorder roundedAppBar = RoundedRectangleBorder(borderRadius: Borders.roundedBottom15);
  static const OutlinedBorder dialogShape = RoundedRectangleBorder(borderRadius: Borders.dialogBorder);
  static const OutlinedBorder bottomSheetShape20 = RoundedRectangleBorder(borderRadius: Borders.roundedTop20);
  static const OutlinedBorder roundedShape10 = RoundedRectangleBorder(borderRadius: Borders.roundedAll10);
}
