import 'package:flutter/material.dart';

final lightColorTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: const Color(0xFFFFFFFF),
  iconTheme: const IconThemeData(
    color: Color(0xFF763BD7),
  ),
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF763BD7),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF763BD7),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFEEE3FF),
    onSecondaryContainer: Color(0xFF6726CE),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF101010),
    surfaceVariant: Color(0xFFF3F3F3),
    onSurfaceVariant: Color(0xFF101010),
    background: Color(0xFFF7F7FF),
    onBackground: Color(0xFF1F1F42),
    outlineVariant: Color(0xFFCCCCCC),
  ),
);

final darkColorTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: const Color(0xFF1D1B1E),
  iconTheme: const IconThemeData(
    color: Color(0xFFD4BBFF),
  ),
  colorScheme: const ColorScheme.light(
    primary: Color(0xFFD4BBFF),
    onPrimary: Color(0xFF40008C),
    secondary: Color(0xFFCDC2DB),
    onSecondary: Color(0xFF342D40),
    secondaryContainer: Color(0xFF4B4358),
    onSecondaryContainer: Color(0xFFEADEF8),
    surface: Color(0xFF1D1B1E),
    onSurface: Color(0xFFE6E1E6),
    surfaceVariant: Color(0xFF49454E),
    onSurfaceVariant: Color(0xFFCBC4CF),
    background: Color(0xFF1D1B1E),
    onBackground: Color(0xFFE6E1E6),
    outlineVariant: Color(0xFFCCCCCC),
  ),
);
