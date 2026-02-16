import 'package:flutter/material.dart';

class TakePillButton extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onPressed;

  const TakePillButton({
    super.key,
    required this.isEnabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1976D2),
          disabledBackgroundColor: Colors.grey.shade400,
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white70,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: isEnabled ? 4 : 0,
        ),
        child: const Text(
          'I TOOK MY PILL',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
