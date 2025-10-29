import 'package:flutter/material.dart';
import 'package:flutter_application_1/themes/app_theme.dart';
import '../components/menu_btn.dart';
import 'game_view.dart';

class ScoreScreen extends StatelessWidget {
  const ScoreScreen({
    super.key,
    required this.timeRestriction,
    required this.highScore,
    required this.finalScore,
  });

  final bool timeRestriction;
  final int highScore;
  final int finalScore;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game Over')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Game Over!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Score: $finalScore',
              style: const TextStyle(fontSize: 16, color: AppTheme.textColor),
            ),
            const SizedBox(height: 12),
            Text(
              'High Score: $highScore',
              style: const TextStyle(fontSize: 16, color: AppTheme.textColor),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.home),
                  label: const Text('Home'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: AppTheme.secondaryMenuBtn,
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameView(
                          timeRestriction: timeRestriction,
                          role: PlayerRole.singleplayer,
                          lobbyId: "",
                        ),
                      ),
                    );
                  },
                  label: const Text('Play Again'),
                  icon: const Icon(Icons.refresh),
                  style: AppTheme.primaryMenuBtn,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
