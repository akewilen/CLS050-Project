import 'package:flutter/material.dart';

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
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.7),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Winner announcement
              Text(
                'Winner: ${_determineWinner()}',
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
                          '$hostId: $hostScore points',
                          style: const TextStyle(
                            fontSize: 24,
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
                          '$guestId: $guestScore points',
                          style: const TextStyle(
                            fontSize: 24,
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
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).primaryColor,
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
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
