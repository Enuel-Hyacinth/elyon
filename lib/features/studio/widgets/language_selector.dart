import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/studio_controller.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  static const List<String> _languages = [
    "English",
    "Spanish",
    "French",
    "German",
    "Italian",
    "Portuguese",
    "Dutch",
    "Russian",
    "Arabic",
    "Hindi",
    "Chinese",
    "Japanese",
    "Korean",
    "Turkish",
    "Swahili",
    "Yoruba",
    "Igbo",
    "Hausa",
  ];

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<StudioController>();

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
              "Language",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: controller.language,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.language),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _languages
                  .map(
                    (language) => DropdownMenuItem(
                      value: language,
                      child: Text(language),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.setLanguage(value);
                }
              },
            ),

            const SizedBox(height: 20),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _languages.take(8).map((language) {
                final selected =
                    controller.language == language;

                return ChoiceChip(
                  label: Text(language),
                  selected: selected,
                  onSelected: (_) {
                    controller.setLanguage(language);
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