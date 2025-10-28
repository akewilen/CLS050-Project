import 'package:flutter/material.dart';
import 'package:flutter_application_1/themes/app_theme.dart';
import '../components/menu_btn.dart';
import 'home_screen.dart';

class MultiplayerScoreScreen extends StatelessWidget {
  const MultiplayerScoreScreen({
    super.key,
    required this.hostId,
    required this.guestId,
    required this.hostScore,
    required this.guestScore,
  });

  final String hostId;
  final String guestId;
  final int hostScore;
  final int guestScore;

  String _result() {
    String winner = _determineWinner();
    if (winner == "You") {
      return "You won!";
    } else if (winner == "It's a tie!") {
      return "It's a tie!";
    } else {
      return "You lost";
    }
  }

  String _determineWinner() {
    if (hostScore > guestScore) {
      return hostId;
    } else if (guestScore > hostScore) {
      return guestId;
    } else {
      return "It's a tie!";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.windowBase, AppTheme.window90],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Winner announcement
              Text(
                _result(), //Winner msg
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),

              // Scores container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Host score
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          hostId == 'You'
                              ? 'Your score: $hostScore points'
                              : 'Your score: $guestScore points',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Guest score
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person_outline, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          hostId == 'You'
                              ? '$guestId: $guestScore points'
                              : '$hostId: $hostScore points',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Home button
              MenuBtn(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false, // Remove all previous routes
                  );
                },
                btnText: 'Home',
                icon: Icon(Icons.home),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
