import 'package:flutter/material.dart';

/// Central place for app-wide theme values.
class AppTheme {
  static final ThemeData theme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.green,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black),
    ),
  );

  static const TextStyle countryNameTextStyle = TextStyle(color: Colors.white, fontSize: 36);
  static const TextStyle statisticTypeTextStyle = TextStyle(color: Colors.white, fontSize: 16);
  static const TextStyle statisticTextStyle = TextStyle(color: Color(0xAAF4D448), fontSize: 40);


  static final ButtonStyle upperCompareButton = ButtonStyle(
    backgroundColor: WidgetStateProperty.all(AppTheme.gold),
    fixedSize: WidgetStateProperty.all<Size>(Size(200.0, 50.0)));

  static final ButtonStyle lowerCompareButton = ButtonStyle(
    backgroundColor: WidgetStateProperty.all(AppTheme.purple),
    fixedSize: WidgetStateProperty.all<Size>(Size(200.0, 50.0)));

  /// Window color used for container backgrounds.
  static const Color gold = Color(0xAAF4D448);
  static const Color purple = Color(0xAA2A1A4A);
  static const Color windowBase = Color(0xFF2A1A4A);
  static const Color window90 = Color(0xE52A1A4A);
}
