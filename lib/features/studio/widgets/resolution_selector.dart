import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/studio_controller.dart';

class ResolutionSelector extends StatelessWidget {
  const ResolutionSelector({super.key});

  static const List<String> _resolutions = [
    "720p HD",
    "1080p Full HD",
    "1440p 2K",
    "2160p 4K",
    "4320p 8K",
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
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            const Text(
              "Output Resolution",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: controller.resolution,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.high_quality,
                ),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
              items: _resolutions
                  .map(
                    (resolution) =>
                        DropdownMenuItem(
                      value: resolution,
                      child: Text(resolution),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.setResolution(value);
                }
              },
            ),

            const SizedBox(height: 20),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _resolutions.map((resolution) {

                final selected =
                    controller.resolution ==
                        resolution;

                return ChoiceChip(
                  label: Text(resolution),
                  selected: selected,
                  onSelected: (_) {
                    controller.setResolution(
                      resolution,
                    );
                  },
                );

              }).toList(),
            ),

            const SizedBox(height: 20),

            Container(
              padding:
                  const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: Row(
                children: [

                  const Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      _resolutionInfo(
                        controller.resolution,
                      ),
                      style: const TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ),

                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  String _resolutionInfo(
      String resolution) {

    switch (resolution) {

      case "720p HD":
        return "Fastest generation with low credit usage.";

      case "1080p Full HD":
        return "Balanced quality and speed.";

      case "1440p 2K":
        return "Sharper visuals for premium content.";

      case "2160p 4K":
        return "Ultra HD output for professional videos.";

      case "4320p 8K":
        return "Highest quality. Requires more credits and rendering time.";

      default:
        return "";
    }
  }
}