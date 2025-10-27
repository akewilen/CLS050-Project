import 'package:flutter/material.dart';
import 'package:flutter_application_1/themes/app_theme.dart';

class MapInstruction extends StatelessWidget {
  final String hiddenCountry;
  const MapInstruction({super.key, required this.hiddenCountry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 16, left: 32, right: 16),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        color: AppTheme.window90,
      ),
      child: Text(
        style: TextStyle(color: Colors.white),
        'Find: $hiddenCountry',
      ),
    );
  }
}
