import 'package:flutter/cupertino.dart';

class Borders {
  Borders._();

  static const BorderRadius roundedAll5 = BorderRadius.all(Radius.circular(5));
  static const BorderRadius roundedAll8 = BorderRadius.all(Radius.circular(8));
  static const BorderRadius roundedAll10 = BorderRadius.all(Radius.circular(10));
  static const BorderRadius roundedAll15 = BorderRadius.all(Radius.circular(15));
  static const BorderRadius roundedAll20 = BorderRadius.all(Radius.circular(20));

  static const BorderRadius dialogBorder = roundedAll20;

  static const BorderRadius roundedBottom15 = BorderRadius.only(
    bottomLeft: Radius.circular(15),
    bottomRight: Radius.circular(15),
  );
  static const BorderRadius roundedTop20 = BorderRadius.only(
    topLeft: Radius.circular(15),
    topRight: Radius.circular(15),
  );
}
