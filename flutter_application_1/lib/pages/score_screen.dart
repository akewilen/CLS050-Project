import 'package:flutter/material.dart';
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
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text('Score: $finalScore', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Text(
              'High Score: $highScore',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            GameView(timeRestriction: timeRestriction),
                      ),
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Play Again'),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    /*
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                  */
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('Home'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
