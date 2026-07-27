import 'package:flutter/material.dart';

class OrionThinkingDialog extends StatelessWidget {
  const OrionThinkingDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1F1F1F),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),

            const SizedBox(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                strokeWidth: 5,
                color: Color(0xFF6C63FF),
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              "Orion is thinking...",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 14),

            const Text(
              "Analyzing your prompt\nand preparing the perfect creative direction.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}