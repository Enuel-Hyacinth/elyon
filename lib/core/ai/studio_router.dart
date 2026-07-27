import 'package:flutter/material.dart';

import '../../features/animation/presentation/animation_screen.dart';

import 'ai_intent.dart';

class StudioRouter {
  static void openStudio(
    BuildContext context,
    AIIntent intent,
  ) {
    switch (intent) {

      case AIIntent.animation:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AnimationScreen(),
          ),
        );
        break;

      case AIIntent.story:

      case AIIntent.marketing:

      case AIIntent.education:

      case AIIntent.music:

      case AIIntent.unknown:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "? ${intent.name.toUpperCase()} Studio is coming soon!",
            ),
          ),
        );
    }
  }
}