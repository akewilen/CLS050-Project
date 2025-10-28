import 'package:flutter/material.dart';
import 'package:flutter_application_1/themes/app_theme.dart';

class LivesRemaining extends StatelessWidget {
  final int lives;
  const LivesRemaining({super.key, required this.lives});

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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
        Icons.favorite,
        color: Colors.red,
        size: 24.0,
          ),
          const SizedBox(width: 8),
          Text(
        '$lives',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
          ),
        ],
      ),
    );
  }
}
