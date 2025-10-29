import 'package:flutter/material.dart';

/// Central place for app-wide theme values.
class AppTheme {
  static final ThemeData theme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.green,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color.fromARGB(255, 190, 52, 52)),
      bodyMedium: TextStyle(color: Color.fromARGB(255, 147, 34, 34)),
    ),
  );

  static const TextStyle highScoreTextStyle = TextStyle(
    color: AppTheme.textColor,
    fontWeight: FontWeight.w500,
    fontSize: 24,
  );

  static const TextStyle test = TextStyle(fontSize: 36);

  static const TextStyle countryNameTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 36,
  );
  static const TextStyle statisticTypeTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 16,
  );
  static const TextStyle statisticTextStyle = TextStyle(
    color: Color(0xAAF4D448),
    fontSize: 40,
  );

  static final ButtonStyle menuBtn = ButtonStyle(
    backgroundColor: WidgetStateProperty.all(AppTheme.btnGold),
    fixedSize: WidgetStateProperty.all<Size>(Size(200.0, 48.0)),
    //minimumSize: const Size(200, 48);
  );

  static final ButtonStyle primaryMenuBtn = ButtonStyle(
    backgroundColor: WidgetStateProperty.all(AppTheme.btnGold),
    fixedSize: WidgetStateProperty.all<Size>(Size(150.0, 48.0)),
    //minimumSize: const Size(200, 48);
  );

  static final ButtonStyle secondaryMenuBtn = ButtonStyle(
    backgroundColor: WidgetStateProperty.all(AppTheme.textColor),
    fixedSize: WidgetStateProperty.all<Size>(Size(110.0, 48.0)),
    //minimumSize: const Size(200, 48);
  );

  /*
  static late ButtonStyle menuBtnn(Icon icon) => ElevatedButton.icon(
    icon: const Icon(icon),
    label: const Text('Multiplayer'),
    backgroundColor: WidgetStateProperty.all(AppTheme.gold),
    fixedSize: WidgetStateProperty.all<Size>(Size(200.0, 50.0)),
  );
*/

  static final ButtonStyle upperCompareButton = ButtonStyle(
    backgroundColor: WidgetStateProperty.all(AppTheme.gold),
    foregroundColor: WidgetStateProperty.all(AppTheme.windowBase),
    fixedSize: WidgetStateProperty.all<Size>(Size(200.0, 50.0)),
  );

  static final ButtonStyle lowerCompareButton = ButtonStyle(
    backgroundColor: WidgetStateProperty.all(AppTheme.lightPurple),
    foregroundColor: WidgetStateProperty.all(AppTheme.windowBase),
    fixedSize: WidgetStateProperty.all<Size>(Size(200.0, 50.0)),
  );

  /// Window color used for container backgrounds.
  static const Color gold = Color(0xAAF4D448);
  static const Color btnGold = Color(0xFFF4D448);
  static const Color lightPurple = Color(0xFF8556E4);
  static const Color liPuTransp = Color(0x4A8556E4);
  static const Color textColor = Color.fromARGB(206, 255, 255, 255);
  static const Color purple = Color(0xAA2A1A4A);
  static const Color windowBase = Color(0xFF2A1A4A);
  static const Color window90 = Color(0xE52A1A4A);
}
