import 'package:flutter/material.dart';

Color colorFromHexString(String hexString, [Color? fallback]) {
  if (!hexString.startsWith('#') || (hexString.length != 7 && hexString.length != 9)) {
    throw ArgumentError('Invalid color hex $hexString');
  }
  final colorValue = int.tryParse(hexString.substring(1), radix: 16);
  if (colorValue == null) {
    if (fallback != null) {
      return fallback;
    }
    throw ArgumentError('Invalid color hex $hexString');
  }
  return Color(colorValue);
}

extension ColorX on Color {
  String get hexString => '#${[alpha, red, green, blue].map((c) => c.toRadixString(16)).join()}';

  bool get isDark => ThemeData.estimateBrightnessForColor(this) == Brightness.dark;
}
