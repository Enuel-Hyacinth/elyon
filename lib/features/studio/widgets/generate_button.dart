import 'package:flutter/material.dart';

import '../controllers/studio_controller.dart';

class GenerateButton extends StatelessWidget {
  final StudioController controller;

  const GenerateButton({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasCredits = controller.hasCredits;
    final bool generating = controller.generating;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [

        //--------------------------------------------------
        // CREDIT WARNING
        //--------------------------------------------------

        if (!hasCredits)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: const [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "You don't have enough AI credits.",
                  ),
                ),
              ],
            ),
          ),

        //--------------------------------------------------
        // GENERATE BUTTON
        //--------------------------------------------------

        SizedBox(
          height: 58,
          child: FilledButton.icon(
            onPressed: (!hasCredits || generating)
                ? null
                : () {
                    controller.startGeneration();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "AI generation started...",
                        ),
                      ),
                    );
                  },
            icon: generating
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(
              generating
                  ? "Generating..."
                  : "Generate AI Content",
            ),
          ),
        ),

        const SizedBox(height: 16),

                //--------------------------------------------------
        // PROGRESS
        //--------------------------------------------------

        if (generating) ...[
          LinearProgressIndicator(
            value: controller.progress == 0
                ? null
                : controller.progress,
          ),

          const SizedBox(height: 12),

          Text(
            "${(controller.progress * 100).toStringAsFixed(0)}% Complete",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () {
                controller.cancelGeneration();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Generation cancelled."),
                  ),
                );
              },
              icon: const Icon(Icons.close),
              label: const Text("Cancel Generation"),
            ),
          ),
        ] else ...[
          SizedBox(
            height: 50,
            child: OutlinedButton.icon(
              onPressed: hasCredits
                  ? () {
                      controller.startGeneration();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Retrying generation..."),
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
            ),
          ),
        ],

        const SizedBox(height: 24),

        //--------------------------------------------------
        // QUEUE STATUS
        //--------------------------------------------------

        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: ListTile(
            leading: const Icon(Icons.queue),
            title: const Text("Generation Queue"),
            subtitle: Text(
              generating
                  ? "Your project is currently being processed."
                  : "No active jobs.",
            ),
          ),
        ),

        const SizedBox(height: 16),

        //--------------------------------------------------
        // CREDIT SUMMARY
        //--------------------------------------------------

        Card(
          elevation: 0,
          child: ListTile(
            leading: const Icon(Icons.stars),
            title: const Text("Credits"),
            subtitle: Text(
              "${controller.creditsRemaining} available • ${controller.creditsRequired} required",
            ),
            trailing: hasCredits
                ? const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  )
                : const Icon(
                    Icons.error,
                    color: Colors.red,
                  ),
          ),
        ),
      ],
    );
  }
}