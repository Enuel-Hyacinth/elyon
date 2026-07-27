import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/studio_controller.dart';

class VoiceSelector extends StatelessWidget {
  const VoiceSelector({super.key});

  static const List<String> _voices = [
    "Female",
    "Male",
    "Child",
    "Narrator",
    "Documentary",
    "News",
    "Calm",
    "Energetic",
    "Cinematic",
    "Robot",
    "AI Assistant",
    "Podcast",
  ];

  @override
  Widget build(BuildContext context) {
    final controller =
    context.watch<StudioController>();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
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
              "Voice",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: controller.voice,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.record_voice_over),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _voices
                  .map(
                    (voice) => DropdownMenuItem(
                      value: voice,
                      child: Text(voice),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.setVoice(value);
                }
              },
            ),

            const SizedBox(height: 20),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _voices.map((voice) {
                final selected =
                    controller.voice == voice;

                return ChoiceChip(
                  label: Text(voice),
                  selected: selected,
                  onSelected: (_) {
                    controller.setVoice(voice);
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