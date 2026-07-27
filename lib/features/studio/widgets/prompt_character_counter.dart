import 'package:flutter/material.dart';

class PromptCharacterCounter extends StatelessWidget {
  final int currentLength;
  final int maxLength;

  const PromptCharacterCounter({
    super.key,
    required this.currentLength,
    required this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = maxLength - currentLength;

    final progress =
        (currentLength / maxLength).clamp(0.0, 1.0);

    Color color;

    if (remaining <= 200) {
      color = Colors.red;
    } else if (remaining <= 800) {
      color = Colors.orange;
    } else {
      color = Colors.green;
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "$currentLength / $maxLength characters",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: color.withOpacity(.10),
                borderRadius:
                    BorderRadius.circular(30),
              ),
              child: Text(
                "$remaining left",
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        LinearProgressIndicator(
          value: progress,
          minHeight: 6,
          borderRadius:
              BorderRadius.circular(20),
          backgroundColor:
              Colors.grey.shade200,
          color: color,
        ),
      ],
    );
  }
}