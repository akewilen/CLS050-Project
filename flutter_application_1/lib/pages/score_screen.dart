import 'package:flutter/material.dart';
import './high_score.dart';
//import '../GameLogic.dart';

class ScoreScreen extends StatelessWidget {
  final int score;

  const ScoreScreen({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    //final game = GameLogic.getCurrentGame();
    final args = (ModalRoute.of(context)?.settings.arguments as Map?) ?? {};
    //final correct = (args['correct'] ?? 0) as int;
    final correct = score;
    final total = (args['total'] ?? 0) as int;

    HighScore.setIfHigher(correct); // persist best

    final pct = total > 0 ? (correct / total * 100).toStringAsFixed(1) : '0.0';

    return Scaffold(
      appBar: AppBar(title: const Text('Score')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'You got $correct / $total correct',
                style: const TextStyle(fontSize: 22),
              ),
              const SizedBox(height: 8),
              Text(
                '$pct %',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/game'),
                child: const Text('Play Again'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                  (r) => false,
                ),
                child: const Text('Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
