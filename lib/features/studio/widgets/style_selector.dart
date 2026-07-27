import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/studio_controller.dart';

class StyleSelector extends StatelessWidget {
  const StyleSelector({super.key});

  static const List<String> _styles = [
    "Cinematic",
    "Anime",
    "Disney",
    "Pixar",
    "3D",
    "Realistic",
    "Comic",
    "Cyberpunk",
    "Fantasy",
    "Sci-Fi",
    "Oil Painting",
    "Watercolor",
    "Low Poly",
    "Clay",
    "Noir",
    "Sketch",
  ];

  @override
  Widget build(BuildContext context) {
    final controller =
    context.watch<StudioController>();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Visual Style",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 18),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _styles.map((style) {
                final selected =
                    controller.style == style;

                return ChoiceChip(
                  label: Text(style),
                  selected: selected,

                  onSelected: (_) {
                    controller.setStyle(style);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}