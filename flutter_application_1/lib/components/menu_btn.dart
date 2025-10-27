import 'package:flutter/material.dart';
import 'package:flutter_application_1/themes/app_theme.dart';

class MenuBtn extends StatelessWidget {
  const MenuBtn({
    super.key,
    required this.onPressed,
    required this.btnText,
    required this.icon,
  });

  /// Callback that will be called when the user confirms quitting
  final VoidCallback onPressed;
  final String btnText;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: icon,
      label: Text(btnText),
      onPressed: onPressed,
      style: AppTheme.menuBtn,
      //style: ElevatedButton.styleFrom(minimumSize: const Size(200, 48)),
    );
  }
}


/*
Positioned(
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
  */