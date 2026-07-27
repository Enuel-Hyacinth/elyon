import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/studio_controller.dart';

class DurationSelector extends StatelessWidget {
  const DurationSelector({super.key});

  static const List<int> durations = [
    5,
    10,
    15,
    30,
    45,
    60,
    90,
    120,
    180,
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<StudioController>(
      builder: (_, controller, __) {
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
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  "Duration",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: durations.map((seconds) {
                    final selected =
                        int.parse(
                          controller.duration.split(" ").first,
                          ) ==
                            seconds;

                    return ChoiceChip(
                      label: Text("$seconds sec"),
                      selected: selected,
                      onSelected: (_) {
                        controller.setDuration(
                          "$seconds Seconds",                          
                        );
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                Text(
                  "Custom Duration (${controller.duration})",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                Slider(
                   value: double.parse(
                   controller.duration.split(" ").first,
                   ),
                   min: 5,
                   max: 300,
                   divisions: 59,
                   label: controller.duration,
  

                  onChanged: (value) {
                    controller.setDuration(
                      "${value.round()} Seconds",
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}