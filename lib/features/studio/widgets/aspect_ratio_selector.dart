import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/studio_controller.dart';

class AspectRatioSelector extends StatelessWidget {
  const AspectRatioSelector({super.key});

  static const List<String> _ratios = [
    "16:9",
    "9:16",
    "1:1",
    "4:5",
    "3:2",
    "2:3",
    "21:9",
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<StudioController>(
      builder: (context, controller, _) {
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.grey.shade300,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text(
                  "Aspect Ratio",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 12),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _ratios.map((ratio) {
                    final selected =
                        controller.aspectRatio == ratio;

                    return ChoiceChip(
                      label: Text(ratio),
                      selected: selected,
                      onSelected: (_) =>
                          controller.setAspectRatio(ratio),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 170,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: AspectRatio(
                      aspectRatio:
                          _aspectRatioValue(controller.aspectRatio),
                      child: AnimatedContainer(
                        duration:
                            const Duration(milliseconds: 250),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            controller.aspectRatio,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  _description(controller.aspectRatio),
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static double _aspectRatioValue(String ratio) {
    switch (ratio) {
      case "16:9":
        return 16 / 9;

      case "9:16":
        return 9 / 16;

      case "1:1":
        return 1;

      case "4:5":
        return 4 / 5;

      case "3:2":
        return 3 / 2;

      case "2:3":
        return 2 / 3;

      case "21:9":
        return 21 / 9;

      default:
        return 16 / 9;
    }
  }

  static String _description(String ratio) {
    switch (ratio) {
      case "16:9":
        return "Best for YouTube, TV and desktop.";

      case "9:16":
        return "Perfect for TikTok, Reels and Shorts.";

      case "1:1":
        return "Ideal for Instagram feed.";

      case "4:5":
        return "Optimized for mobile social feeds.";

      case "3:2":
        return "Photography standard.";

      case "2:3":
        return "Portrait photography.";

      case "21:9":
        return "Ultra-wide cinematic movies.";

      default:
        return "";
    }
  }
}