import 'package:flutter/material.dart';


class QuitButton extends StatelessWidget {
  const QuitButton({
    super.key,
    required this.onQuitConfirmed,
  });

  /// Callback that will be called when the user confirms quitting
  final VoidCallback onQuitConfirmed;

  /// Shows a confirmation dialog and returns true if user confirms quitting
  Future<bool> _showQuitConfirmation(BuildContext context) async {
    final bool? shouldQuit = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Quit Game'),
          content: const Text('Do you want to leave the game?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Quit'),
            ),
          ],
        );
      },
    );

    return shouldQuit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20,
      left: 20,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.close),
          color: Colors.black,
          iconSize: 24,
          onPressed: () async {
            final bool shouldQuit = await _showQuitConfirmation(context);
            if (shouldQuit && context.mounted) {
              onQuitConfirmed();
            }
          },
        ),
      ),
    );
  }
}
